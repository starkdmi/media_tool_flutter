import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

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
  Stream<VideoCompressEvent> startVideoCompression({
    required String id,
    required String path,
    required String destination,
    VideoSettings videoSettings = const VideoSettings(),
    bool skipAudio = false,
    AudioSettings audioSettings = const AudioSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async* {
    try {
      // Initialize the compression process
      await methodChannel.invokeMethod<bool>('startVideoCompression', {
        'id': id,
        'path': path,
        'destination': destination,
        'video': videoSettings.toMap(),
        'skipAudio': skipAudio,
        'audio': skipAudio ? null : audioSettings.toMap(),
        'overwrite': overwrite,
        'deleteOrigin': deleteOrigin,
      }); // nil

      final stream = EventChannel('media_tool.video_compression.$id')
        .receiveBroadcastStream();

      // Map events from native platform into Dart based events
      await for (final event in stream) {
        if (event is bool) {
          if (event) {
            // started
            yield const VideoCompressStartedEvent();
          } else {
            // cancelled
            yield const VideoCompressCancelledEvent();
          }
        } else if (event is double) {
          // progress
          yield VideoCompressProgressEvent(progress: event);
        } else if (event is String) {
          yield VideoCompressCompletedEvent(url: event);
        } /*else {
          throw UnimplementedError("VideoCompressEvent for this data type isn't implemented");
        }*/
      }
    } catch (error) {
      // failed
      yield VideoCompressFailedEvent(error: error.toString());
    }
  }

  @override
  Stream<VideoCompressEvent> startAudioCompression({
    required String id,
    required String path,
    required String destination,
    AudioSettings settings = const AudioSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async* {
    try {
      // Initialize the compression process
      await methodChannel.invokeMethod<bool>('startAudioCompression', {
        'id': id,
        'path': path,
        'destination': destination,
        'audio': settings.toMap(),
        'overwrite': overwrite,
        'deleteOrigin': deleteOrigin,
      }); // nil

      final stream = EventChannel('media_tool.audio_compression.$id')
        .receiveBroadcastStream();

      // Map events from native platform into Dart based events
      await for (final event in stream) {
        if (event is bool) {
          if (event) {
            // started
            yield const VideoCompressStartedEvent();
          } else {
            // cancelled
            yield const VideoCompressCancelledEvent();
          }
        } else if (event is double) {
          // progress
          yield VideoCompressProgressEvent(progress: event);
        } else if (event is String) {
          yield VideoCompressCompletedEvent(url: event);
        } /*else {
          throw UnimplementedError("VideoCompressEvent for this data type isn't implemented");
        }*/
      }
    } catch (error) {
      // failed
      yield VideoCompressFailedEvent(error: error.toString());
    }
  }

  @override
  Future<bool> cancelCompression(String id) async {
    // Cancel video compression process
    return await methodChannel.invokeMethod<bool>('cancelCompression', { 'id': id }) ?? false;
  }

  /// Convert image file
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [settings] - Image settings: format, quality, size
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input image file be deleted on succeed compression
  @override
  Future<ImageInfo?> imageCompression({
    required String path,
    required String destination,
    ImageSettings settings = const ImageSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async {
    final data = await methodChannel.invokeMethod<Map<String, dynamic>>('imageCompression', {
      'path': path,
      'destination': destination,
      'settings': settings.toMap(),
      'overwrite': overwrite,
      'deleteOrigin': deleteOrigin,
    });

    return data == null ? null : ImageInfo.fromMap(data);
  }
}
