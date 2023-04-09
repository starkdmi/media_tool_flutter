#if os(iOS)
import Flutter
import UIKit
#elseif os(OSX)
import FlutterMacOS
import Foundation
#endif

public class MediaToolPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
    let channel = FlutterMethodChannel(
      name: "media_tool_ios", 
      binaryMessenger: registrar.messenger()
    )
    #elseif os(OSX)
    let channel = FlutterMethodChannel(
      name: "media_tool_macos", 
      binaryMessenger: registrar.messenger
    )
    #endif
    let instance = MediaToolPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformName":
      #if os(iOS)
      result("iOS")
      #elseif os(OSX)
      result("MacOS")    
      #endif
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
