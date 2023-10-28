/*import Foundation

/// File Logger
/// Usage: print(Date(), #file, #function, "Hello World!", to: &Logger.logger)
/// Logs directory: Bundle.main.bundleURL.absoluteString
public class Logger: TextOutputStream {
    /// Private initializer for singleton
    private init() {}

    /// Singleton
    public static var logger: Logger = Logger()

    /// Write logs to file
    public func write(_ string: String) {
        let directory = URL(fileURLWithPath: Bundle.main.bundleURL.absoluteString).deletingLastPathComponent()
        let file = directory.appendingPathComponent("media_tool_swift_log.txt")
        if let handle = try? FileHandle(forWritingTo: file) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? string.data(using: .utf8)?.write(to: file)
        }
    }
}*/
