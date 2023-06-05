import MediaToolSwift
import AVFoundation

#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

public extension FlutterError {
    convenience init(_ message: String) {
        self.init(
            code: "CompressionError",
            message: message,
            details: nil
        )
    }
}

public class MediaToolPlugin: NSObject, FlutterPlugin {
    static var messenger: FlutterBinaryMessenger?

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        Self.messenger = registrar.messenger()
        #elseif os(OSX)
        Self.messenger = registrar.messenger
        #endif

        let channel = FlutterMethodChannel(
            name: "media_tool",
            binaryMessenger: Self.messenger!
        )
        let instance = MediaToolPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private var operations: [String: (task: CompressionTask, stream: FlutterStreamHandler)] = [:]

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformName":
            #if os(iOS)
            result("iOS")
            #elseif os(OSX)
            result("macOS")
            #endif
        case "startVideoCompression":
            startVideoCompression(call: call, result: result)
        case "cancelVideoCompression":
            cancelVideoCompression(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startVideoCompression(call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError("Empty arguments passed to the call"))
            return
        }

        guard let uid = arguments["id"] as? String, operations[uid] == nil else {
            result(FlutterError("Invalid or non-unique ID"))
            return
        }

        guard
            let path = arguments["path"] as? String,
            let destination = arguments["destination"] as? String,
            let skipAudio = arguments["skipAudio"] as? Bool,
            let overwrite = arguments["overwrite"] as? Bool,
            let deleteOrigin = arguments["deleteOrigin"] as? Bool
        else {
            result(FlutterError("Invalid arguments passed to the call"))
            return
        }

        let sourceUrl = URL(fileURLWithPath: path)
        let destinationUrl = URL(fileURLWithPath: destination)

        guard
            let videoOptions = arguments["video"] as? [String: Any],
            let codec = videoOptions["codec"] as? String,
            let bitrate = videoOptions["bitrate"] as? Int,
            let quality = videoOptions["quality"] as? Double,
            let width = videoOptions["width"] as? Double,
            let height = videoOptions["height"] as? Double
        else {
            result(FlutterError("Invalid video settings \(arguments["video"])"))
            return
        }

        let videoSettings = CompressionVideoSettings(
            codec: codec != "" ? AVVideoCodecType(rawValue: codec) : nil,
            bitrate: bitrate != -1 ? .value(bitrate) : .auto,
            quality: quality != -1.0 ? quality : nil,
            size: width != -1.0 && height != -1.0 ? CGSize(width: width, height: height) : nil
        )

        let audioSettings: CompressionAudioSettings?
        if !skipAudio {
            guard let audioOptions = arguments["audio"] as? [String: Any],
                  let codec = audioOptions["codec"] as? Int,
                  let bitrate = audioOptions["bitrate"] as? Int,
                  let sampleRate = audioOptions["sampleRate"] as? Int else {
                    result(FlutterError("Invalid audio settings \(arguments["audio"])"))
                    return
                  }

            audioSettings = CompressionAudioSettings(
                codec: CompressionAudioCodec(rawValue: codec) ?? .default,
                bitrate: bitrate != -1 ? .value(bitrate) : .auto,
                sampleRate: sampleRate != -1 ? sampleRate : nil
            )
        } else {
            audioSettings = nil
        }

        guard let fileType = CompressionFileType(rawValue: destinationUrl.pathExtension) else {
            result(FlutterError("Invalid destination file extension"))
            return
        }

        // Intialize the event channel
        let stream = QueuedStreamHandler(name: "media_tool.video_compression.\(uid)", messenger: Self.messenger!)

        // Event channel had set up
        result(nil)

        // Asynchronous code
        Task.detached {
            do {
                // Start the compression
                let task = await VideoTool.convert(
                    source: sourceUrl,
                    destination: destinationUrl,
                    fileType: fileType,
                    videoSettings: videoSettings,
                    skipAudio: skipAudio,
                    audioSettings: audioSettings,
                    overwrite: overwrite,
                    deleteSourceFile: deleteOrigin,
                    callback: { state in
                        switch state {
                        case .started:
                            stream.sink(true)
                        case .progress(let progress):
                            stream.sink(progress.fractionCompleted)
                        case .completed(let url):
                            stream.sink(url.path)
                            stream.sink(FlutterEndOfEventStream)
                        case .failed(let error):
                            stream.sink(FlutterError(error.localizedDescription))
                            stream.sink(FlutterEndOfEventStream)
                        case .cancelled:
                            stream.sink(false)
                            stream.sink(FlutterEndOfEventStream)
                        }
                    }
                )

                // Store the task
                self.operations[uid] = (task: task, stream: stream)
            } catch let error as NSError {
                stream.sink(FlutterError(error.localizedDescription))
                stream.sink(FlutterEndOfEventStream)
            }
        }
    }

    private func cancelVideoCompression(call: FlutterMethodCall, result: FlutterResult) {
        if let arguments = call.arguments as? [String: Any],
            let uid = arguments["id"] as? String,
            let operation = operations[uid] {
            operation.task.cancel()
            operations[uid] = nil
            result(true)
        } else {
            result(false)
        }
    }
}
