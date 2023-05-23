// ignore_for_file: lines_longer_than_80_chars
import 'dart:async';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
import 'package:media_tool_platform_interface/src/video_compress_event.dart';
import 'package:media_tool_platform_interface/src/video_compress_options.dart';

/// An implementation of [MediaToolPlatform] that uses method channels
class MethodChannelMediaTool extends MediaToolPlatform {
  /// The method channel used to interact with the native platform
  @visibleForTesting
  final methodChannel = const MethodChannel('media_tool');

  /// A channel used to listen to receive video compression state changes
  final videoCompressionStateChannel = const EventChannel('media_tool.video_compression.progress');

  @override
  Future<String?> getPlatformName() {
    // Get native platform name
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<Stream<VideoCompressEvent>> startVideoCompression(VideoCompressOptions options) async {
    // Initialize the compression process
    await methodChannel.invokeMethod<String>('startVideoCompression', options.toMap());

    // Map events from native platform into Dart based events
    return videoCompressionStateChannel.receiveBroadcastStream().map<VideoCompressEvent>((event) {
      if (event is bool) {
        return event ? VideoCompressStartedEvent() : VideoCompressCancelledEvent();
      } else if (event is double) { 
        return VideoCompressProgressEvent(progress: event);
      } else if (event is String) {
        return VideoCompressFailedEvent(error: event);
      } else if (event is Map) {
        final url = event['url'] as String;
        return VideoCompressCompletedEvent(url: url);
      } else {
        throw UnimplementedError("VideoCompressEvent for this data type isn't implemented");
      }
    });
  }

  @override
  Future<void> cancelVideoCompression() async {
    // Cancel video compression process
    await methodChannel.invokeMethod<void>('cancelVideoCompression');
  }
}
