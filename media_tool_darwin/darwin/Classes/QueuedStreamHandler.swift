#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

/// Implementation of `FlutterStreamHandler` which queue messages while not subscribed to
public class QueuedStreamHandler: NSObject, FlutterStreamHandler {
    private var eventChannel: FlutterEventChannel!
    private var eventSink: FlutterEventSink?

    private var accessQueue: DispatchQueue!
    private var queue = [Any]()

    public init(name: String, messenger: FlutterBinaryMessenger) {
        super.init()
        eventChannel = FlutterEventChannel(name: name, binaryMessenger: messenger)
        eventChannel.setStreamHandler(self)
        accessQueue = DispatchQueue(label: "\(name).QueuedStreamHandler.accessQueue")
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        releaseQueue()
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func sink(_ data: Any) {
        accessQueue.sync {
            queue.append(data)
        }
        releaseQueue()
    }

    private func releaseQueue() {
        guard let eventSink = eventSink else { return }

        accessQueue.sync {
            while !self.queue.isEmpty {
                let item = self.queue.removeFirst()
                DispatchQueue.main.async {
                    eventSink(item)
                }
            }
        }
    }
}
