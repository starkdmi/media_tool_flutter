// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

/// Darwin implementation of [VideoCompressOptions]
class VideoCompressOptionsDarwin extends VideoCompressOptions {
  /// Public initializer
  const VideoCompressOptionsDarwin({ 
    required super.id,
    required super.path, 
    required super.destination, 
    required this.x,
  }) : super();

  /// Some property
  final int x;

  /// Generate Map object to pass over the MethodChannel
  @override
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'destination': destination,
      'x' : x 
    };
  }
}

/// The Darwin implementation of [MediaToolPlatform].
class MediaToolDarwin extends MediaToolPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('media_tool');

  /// Registers this class as the default instance of [MediaToolPlatform]
  static void registerWith() {
    MediaToolPlatform.instance = MediaToolDarwin();
  }

  @override
  Future<String?> getPlatformName() {
    // Get native platform name
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Stream<VideoCompressEvent> startVideoCompression(VideoCompressOptions options) async* {
    try {
      // Initialize the compression process
      await methodChannel.invokeMethod<bool>('startVideoCompression', options.toMap()); // nil

      final stream = EventChannel('media_tool.video_compression.${options.id}')
        .receiveBroadcastStream();

      // Map events from native platform into Dart based events
      await for (final event in stream) {
        if (event is bool) {
          if (event) {
            // started
            yield VideoCompressStartedEvent();
          } else {
            // cancelled
            yield VideoCompressCancelledEvent();
          }
        } else if (event is double) {
          // progress
          yield VideoCompressProgressEvent(progress: event);
        } else if (event is String) {
          yield VideoCompressFailedEvent(error: event);
        }
        else if (event is Map) {
          // completed
          final url = event['url'] as String;
          VideoCompressCompletedEvent(url: url);
        } else {
          throw UnimplementedError("VideoCompressEvent for this data type isn't implemented");
        }
      }
    } catch (error) {
      // failed
      yield VideoCompressFailedEvent(error: error.toString());
    }
  }

  @override
  Future<bool> cancelVideoCompression(String id) async {
    // Cancel video compression process
    return await methodChannel.invokeMethod<bool>('cancelVideoCompression', { 'id': id }) ?? false;
  }
}
