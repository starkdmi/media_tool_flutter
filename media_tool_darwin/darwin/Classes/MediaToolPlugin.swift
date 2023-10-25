import MediaToolSwift
import AVFoundation

#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

/// `FlutterError` extension
public extension FlutterError {
    /// Initialize `FlutterError` using `String`
    convenience init(_ message: String) {
        self.init(
            code: "CompressionError",
            message: message,
            details: nil
        )
    }
}

/// MediaTool plugin
public class MediaToolPlugin: NSObject, FlutterPlugin {
    /// Binary messenger
    static var messenger: FlutterBinaryMessenger?

    /// Initialize method channel
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

    /// Active compression operations
    private var operations: [String: (task: CompressionTask, stream: FlutterStreamHandler)] = [:]

    /// Requests router
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startVideoCompression":
            startVideoCompression(call: call, result: result)
        case "startAudioCompression":
            startAudioCompression(call: call, result: result)
        case "cancelCompression":
            cancelCompression(call: call, result: result)
        case "imageCompression":
            imageCompression(call: call, result: result)
        case "videoThumbnails":
            videoThumbnails(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Process video compression request
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

        // Video settings
        guard
            let videoJSON = arguments["video"] as? [String: Any],
            let videoData = try? JSONSerialization.data(withJSONObject: videoJSON),
            let videoSettings = try? JSONDecoder().decode(CompressionVideoSettings.self, from: videoData)
        else {
            result(FlutterError("Invalid video settings \(String(describing: arguments["video"]))"))
            return
        }

        // Audio settings
        var audioSettings: CompressionAudioSettings?
        if !skipAudio, let json = arguments["audio"] as? [String: Any] {
            guard let data = try? JSONSerialization.data(withJSONObject: json),
                let settings = try? JSONDecoder().decode(CompressionAudioSettings.self, from: data)
            else {
                result(FlutterError("Invalid audio settings \(String(describing: arguments["audio"]))"))
                return
            }
            audioSettings = settings
        }

        guard let fileType = VideoFileType(rawValue: destinationUrl.pathExtension) else {
            result(FlutterError("Invalid destination file extension"))
            return
        }

        // Intialize the event channel
        let stream = QueuedStreamHandler(name: "media_tool.video_compression.\(uid)", messenger: Self.messenger!)

        // Event channel is ready
        result(nil)

        // Asynchronous code
        Task.detached {
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
        }
    }

    /// Process audio compression request
    private func startAudioCompression(call: FlutterMethodCall, result: FlutterResult) {
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
            result(FlutterError("Invalid arguments passed to the audio compression call"))
            return
        }

        let sourceUrl = URL(fileURLWithPath: path)
        let destinationUrl = URL(fileURLWithPath: destination)

        // Audio settings
        guard
            let json = arguments["audio"] as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: json),
            let settings = try? JSONDecoder().decode(CompressionAudioSettings.self, from: data)
        else {
            result(FlutterError("Invalid audio settings \(String(describing: arguments["audio"]))"))
            return
        }

        guard let fileType = AudioFileType(rawValue: destinationUrl.pathExtension) else {
            result(FlutterError("Invalid destination file extension"))
            return
        }

        // Intialize the event channel
        let stream = QueuedStreamHandler(name: "media_tool.audio_compression.\(uid)", messenger: Self.messenger!)

        // Event channel is ready
        result(nil)

        // Asynchronous code
        Task.detached {
            // Start the compression
            let task = await AudioTool.convert(
                source: sourceUrl,
                destination: destinationUrl,
                fileType: fileType,
                settings: settings,
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
        }
    }

    /// Cancel compression request by id
    private func cancelCompression(call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let uid = arguments["id"] as? String else {
            result(FlutterError("Invalid arguments passed to the call"))
            return
        }

        if let operation = operations[uid] {
            // Cancel
            operation.task.cancel()
            operations[uid] = nil
            result(true)
        } else {
            // Unknown ID
            result(false)
        }
    }

    /// Process image compression request
    private func imageCompression(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError("Empty arguments passed to the call"))
            return
        }

        guard
            let path = arguments["path"] as? String,
            let destination = arguments["destination"] as? String,
            let overwrite = arguments["overwrite"] as? Bool,
            let deleteOrigin = arguments["deleteOrigin"] as? Bool
        else {
            result(FlutterError("Invalid arguments passed to the audio compression call"))
            return
        }

        let sourceUrl = URL(fileURLWithPath: path)
        let destinationUrl = URL(fileURLWithPath: destination)

        // Image settings
        guard
            let json = arguments["settings"] as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: json),
            let settings = try? JSONDecoder().decode(ImageSettings.self, from: data)
        else {
            result(FlutterError("Invalid image settings \(String(describing: arguments["settings"]))"))
            return
        }

        DispatchQueue.global().async {
            do {
                let info = try ImageTool.convert(
                    source: sourceUrl,
                    destination: destinationUrl,
                    settings: imageSettings,
                    skipMetadata: false,
                    overwrite: overwrite,
                    deleteSourceFile: deleteOrigin
                )

                let data = JSONEncoder().encode(info)
                DispatchQueue.main.async {
                    result(data)
                }
            } catch let error {
                DispatchQueue.main.async {
                    result(FlutterError(error.localizedDescription))
                }
            }
        }
    }

    /// Process video thumbnails request
    private func videoThumbnails(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError("Empty arguments passed to the call"))
            return
        }

        guard
            let path = arguments["path"] as? String,
            let transfrom = arguments["transfrom"] as? Bool,
            let timeToleranceBefore = arguments["timeToleranceBefore"] as? Double,
            let timeToleranceAfter = arguments["timeToleranceAfter"] as? Double
        else {
            result(FlutterError("Invalid arguments passed to the video thumbnails call"))
            return
        }

        // Requests
        guard
            let json = arguments["requests"],
            let data = try? JSONSerialization.data(withJSONObject: json),
            let requests = try? JSONDecoder().decode([VideoThumbnailRequest].self, from: data)
        else {
            result(FlutterError("Invalid video thumbnail requests \(String(describing: arguments["requests"]))"))
            return
        }

        // Image settings
        guard
            let imageJSON = arguments["image"] as? [String: Any],
            let imageData = try? JSONSerialization.data(withJSONObject: imageJSON),
            let imageSettings = try? JSONDecoder().decode(ImageSettings.self, from: imageData)
        else {
            result(FlutterError("Invalid image settings \(String(describing: arguments["image"]))"))
            return
        }

        DispatchQueue.global().async {
            VideoTool.thumbnailFiles(
                of: asset,
                at: requests,
                settings: imageSettings,
                timeToleranceBefore: timeToleranceBefore ?? .zero,
                timeToleranceAfter: timeToleranceAfter ?? .zero,
                completion: { result in
                    switch result {
                    case .success(items): // [VideoThumbnailFile]
                        let data = JSONEncoder().encode(items)
                        DispatchQueue.main.async {
                            result(data)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            result(FlutterError(error.localizedDescription))
                        }
                    }
                }
            )
        }
    }
}
