import MediaToolSwift
import AVFoundation
import os

#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

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
            name: "media_tool_flutter",
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
        case "videoInfo":
            videoInfo(call: call, result: result)
        case "audioInfo":
            audioInfo(call: call, result: result)
        case "imageInfo":
            imageInfo(call: call, result: result)
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
            let skipMetadata = arguments["skipMetadata"] as? Bool,
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
        let audioSettings: CompressionAudioSettings?
        if !skipAudio, let json = arguments["audio"] as? [String: Any] {
            guard let data = try? JSONSerialization.data(withJSONObject: json),
                let settings = try? JSONDecoder().decode(CompressionAudioSettings.self, from: data)
            else {
                result(FlutterError("Invalid audio settings \(String(describing: arguments["audio"]))"))
                return
            }
            audioSettings = settings
        } else {
            audioSettings = nil
        }

        guard let fileType = VideoFileType(rawValue: destinationUrl.pathExtension) else {
            result(FlutterError("Invalid destination file extension"))
            return
        }

        // Intialize the event channel
        let stream = QueuedStreamHandler(name: "media_tool_flutter.video_compression.\(uid)", messenger: Self.messenger!)

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
                skipSourceMetadata: skipMetadata,
                overwrite: overwrite,
                deleteSourceFile: deleteOrigin,
                callback: { state in
                    switch state {
                    case .started:
                        stream.sink(true)
                    case .progress(let progress):
                        stream.sink(progress.fractionCompleted)
                    case .completed(let info):
                        // swiftlint:disable force_try force_cast
                        let data = try! JSONEncoder().encode(info as! VideoInfo)
                        let json = try! JSONSerialization.jsonObject(with: data, options: [])
                        // swiftlint:enable force_try force_cast

                        stream.sink(json)
                        stream.sink(FlutterEndOfEventStream)
                        self.operations[uid] = nil
                    case .failed(let error):
                        stream.sink(FlutterError(error.localizedDescription))
                        stream.sink(FlutterEndOfEventStream)
                        self.operations[uid] = nil
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
            let skipMetadata = arguments["skipMetadata"] as? Bool,
            let overwrite = arguments["overwrite"] as? Bool,
            let deleteOrigin = arguments["deleteOrigin"] as? Bool
        else {
            result(FlutterError("Invalid arguments passed to the call"))
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
        let stream = QueuedStreamHandler(name: "media_tool_flutter.audio_compression.\(uid)", messenger: Self.messenger!)

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
                skipSourceMetadata: skipMetadata,
                overwrite: overwrite,
                deleteSourceFile: deleteOrigin,
                callback: { state in
                    switch state {
                    case .started:
                        stream.sink(true)
                    case .progress(let progress):
                        stream.sink(progress.fractionCompleted)
                    case .completed(let info):
                        // swiftlint:disable force_try force_cast
                        let data = try! JSONEncoder().encode(info as! AudioInfo)
                        let json = try! JSONSerialization.jsonObject(with: data, options: [])
                        // swiftlint:enable force_try force_cast

                        stream.sink(json)
                        stream.sink(FlutterEndOfEventStream)
                        self.operations[uid] = nil
                    case .failed(let error):
                        stream.sink(FlutterError(error.localizedDescription))
                        stream.sink(FlutterEndOfEventStream)
                        self.operations[uid] = nil
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
            let skipMetadata = arguments["skipMetadata"] as? Bool,
            let overwrite = arguments["overwrite"] as? Bool,
            let deleteOrigin = arguments["deleteOrigin"] as? Bool
        else {
            result(FlutterError("Invalid arguments passed to the call"))
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
                    settings: settings,
                    skipMetadata: skipMetadata,
                    overwrite: overwrite,
                    deleteSourceFile: deleteOrigin
                )

                let data = try JSONEncoder().encode(info)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    result(json)
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
            let path = arguments["path"] as? String
        else {
            result(FlutterError("Invalid arguments passed to the call"))
            return
        }

        // Optional arguments
        let transfrom = (arguments["transfrom"] as? Bool) ?? true
        let timeToleranceBefore = (arguments["timeToleranceBefore"] as? Double) ?? .zero
        let timeToleranceAfter = (arguments["timeToleranceAfter"] as? Double) ?? .zero

        let sourceUrl = URL(fileURLWithPath: path)
        let asset = AVAsset(url: sourceUrl)

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
            let imageJSON = arguments["settings"] as? [String: Any],
            let imageData = try? JSONSerialization.data(withJSONObject: imageJSON),
            let imageSettings = try? JSONDecoder().decode(ImageSettings.self, from: imageData)
        else {
            result(FlutterError("Invalid image settings \(String(describing: arguments["settings"]))"))
            return
        }

        DispatchQueue.global().async {
            VideoTool.thumbnailFiles(
                of: asset,
                at: requests,
                settings: imageSettings,
                transfrom: transfrom,
                timeToleranceBefore: timeToleranceBefore,
                timeToleranceAfter: timeToleranceAfter,
                completion: { response in
                    do {
                        switch response {
                        case .success(let files): // [VideoThumbnailFile]
                            let data = try JSONEncoder().encode(files)
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            DispatchQueue.main.async {
                                result(json)
                            }
                        case .failure(let error):
                            throw error
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            result(FlutterError(error.localizedDescription))
                        }
                    }
                }
            )
        }
    }

    /// Get video info
    private func videoInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let path = arguments["path"] as? String else {
            result(FlutterError("Invalid arguments passed to the call"))
            return
        }
        let sourceUrl = URL(fileURLWithPath: path)

        // Asynchronous code
        Task.detached {
            do {
                let info = try await VideoTool.getInfo(source: sourceUrl)

                let data = try JSONEncoder().encode(info)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                result(json)
            } catch let error {
                result(FlutterError(error.localizedDescription))
            }
        }
    }

    /// Get audio info
    private func audioInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let path = arguments["path"] as? String else {
            result(FlutterError("Invalid arguments passed to the call"))
            return
        }
        let sourceUrl = URL(fileURLWithPath: path)

        // Asynchronous code
        Task.detached {
            do {
                let info = try await AudioTool.getInfo(source: sourceUrl)

                let data = try JSONEncoder().encode(info)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                result(json)
            } catch let error {
                result(FlutterError(error.localizedDescription))
            }
        }
    }

    /// Get image info
    private func imageInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let path = arguments["path"] as? String else {
            result(FlutterError("Invalid arguments passed to the call"))
            return
        }
        let sourceUrl = URL(fileURLWithPath: path)

        DispatchQueue.global().async {
            do {
                let info = try ImageTool.getInfo(source: sourceUrl)

                let data = try JSONEncoder().encode(info)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    result(json)
                }
            } catch let error {
                DispatchQueue.main.async {
                    result(FlutterError(error.localizedDescription))
                }
            }
        }
    }
}
