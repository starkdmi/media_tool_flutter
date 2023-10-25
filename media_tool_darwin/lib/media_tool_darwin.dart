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
  Stream<CompressionEvent> startVideoCompression({
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
        'video': videoSettings.toJson(),
        'skipAudio': skipAudio,
        'audio': skipAudio ? null : audioSettings.toJson(),
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
            yield const CompressionStartedEvent();
          } else {
            // cancelled
            yield const CompressionCancelledEvent();
          }
        } else if (event is double) {
          // progress
          yield CompressionProgressEvent(progress: event);
        } else if (event is String) {
          yield CompressionCompletedEvent(url: event);
        } /*else {
          throw UnimplementedError("VideoCompressEvent for this data type isn't implemented");
        }*/
      }
    } catch (error) {
      // failed
      yield CompressionFailedEvent(error: error.toString());
    }
  }

  @override
  Stream<CompressionEvent> startAudioCompression({
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
        'audio': settings.toJson(),
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
            yield const CompressionStartedEvent();
          } else {
            // cancelled
            yield const CompressionCancelledEvent();
          }
        } else if (event is double) {
          // progress
          yield CompressionProgressEvent(progress: event);
        } else if (event is String) {
          yield CompressionCompletedEvent(url: event);
        } /*else {
          throw UnimplementedError("VideoCompressEvent for this data type isn't implemented");
        }*/
      }
    } catch (error) {
      // failed
      yield CompressionFailedEvent(error: error.toString());
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
    // Run the image compression
    final data = await methodChannel.invokeMethod<Map<Object?, Object?>>('imageCompression', {
      'path': path,
      'destination': destination,
      'settings': settings.toJson(),
      'overwrite': overwrite,
      'deleteOrigin': deleteOrigin,
    });

    // Convert dict key from `Object?` to `String`
    final dict = data?.map((key, value) {
      return MapEntry<String, Object?>(key is String ? key : key.toString(), value);
    });

    return dict == null ? null : ImageInfo.fromJson(dict);
  }
}
