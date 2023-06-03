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
            let codec = videoOptions["codec"] as? String?,
            let bitrate = videoOptions["bitrate"] as? Int?,
            let quality = videoOptions["quality"] as? Double?,
            let width = videoOptions["width"] as? Int?,
            let height = videoOptions["height"] as? Int?
        else {
            result(FlutterError("Invalid video settings"))
            return
        }
        
        let videoSettings = CompressionVideoSettings(
            codec: codec != nil ? AVVideoCodecType(rawValue: codec!) : nil,
            bitrate: bitrate != nil ? .value(bitrate!) : .auto,
            quality: quality,
            size: width != nil && height != nil ? CGSize(width: width!, height: height!) : nil
        )
        
        let skipAudio: Bool
        let audioSettings: CompressionAudioSettings
        let audioOptions = arguments["audio"] as? [String: Any]
        if let audioOptions = audioOptions {
            guard
                let codec = audioOptions["codec"] as? Int?,
                let bitrate = audioOptions["bitrate"] as? Int?,
                let sampleRate = audioOptions["sampleRate"] as? Int?
            else {
                result(FlutterError("Invalid audio settings"))
                return
            }
            skipAudio = false
            
            // TODO: After updating MediaToolSwift to 1.0.2 CompressionAudioCodec(rawValue:) can be used
            let audioCodec: CompressionAudioCodec
            switch codec {
            case 1: audioCodec = .aac
            case 2: audioCodec = .opus
            case 3: audioCodec = .flac
            default: audioCodec = .default
            }
            
            audioSettings = CompressionAudioSettings(
                codec: audioCodec,
                // codec: codec != nil ? CompressionAudioCodec(rawValue: codec!) : .default,
                bitrate: bitrate != nil ? .value(bitrate!) : .auto,
                sampleRate: sampleRate
            )
        } else {
            skipAudio = true
            audioSettings = CompressionAudioSettings()
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
        Task {
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
            operations[uid] = (task: task, stream: stream)
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
