import MediaToolSwift

#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

/*public struct PluginOperation {
    let task: CompressionTask
    let stream: FlutterStreamHandler
}*/

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
            guard
                let arguments = call.arguments as? [String: Any],
                let uid = arguments["id"] as? String, operations[uid] == nil,
                let path = arguments["path"] as? String,
                let destination = arguments["destination"] as? String
            else {
                let flutterError = FlutterError(
                    code: "CompressionError",
                    message: "Invalid arguments passed to the call",
                    details: nil
                )
                result(flutterError)
                return
            }

            let sourceUrl = URL(fileURLWithPath: path)
            let destinationUrl = URL(fileURLWithPath: destination)

            // Intialize the event channel
            let stream = QueuedStreamHandler(name: "media_tool.video_compression.\(uid)", messenger: Self.messenger!)

            // Event channel had set up
            result(nil)

            Task {
                // Start the compression
                let task = await VideoTool.convert(
                    source: sourceUrl,
                    destination: destinationUrl,
                    fileType: .mov,
                    videoSettings: CompressionVideoSettings(codec: .hevc, size: .fhd),
                    audioSettings: CompressionAudioSettings(codec: .opus, bitrate: .value(96_000)),
                    overwrite: true,
                    callback: { state in
                        switch state {
                        case .started:
                            stream.sink(true)
                        case .progress(let progress):
                            stream.sink(progress.fractionCompleted)
                        case .completed(let url):
                            stream.sink(url.absoluteString)
                            stream.sink(FlutterEndOfEventStream)
                        case .failed(let error):
                            let flutterError = FlutterError(
                                code: "CompressionError",
                                message: error.localizedDescription,
                                details: nil
                            )
                            stream.sink(flutterError)
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
        case "cancelVideoCompression":
            if let arguments = call.arguments as? [String: Any],
               let uid = arguments["id"] as? String,
               let operation = operations[uid] {
                operation.task.cancel()
                operations[uid] = nil
                result(true)
            } else {
                result(false)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
