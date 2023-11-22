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

  /// Compress video file
  /// [id] - Unique process ID
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [videoSettings] - Video settings: codec, bitrate, quality, resolution
  /// [skipAudio] - If `true` then audio is skipped
  /// [audioSettings] - Audio settings: codec, bitrate, sampleRate
  /// [skipMetadata] - Flag to skip source video metadata
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input video file be deleted on succeed compression
  @override
  Stream<CompressionEvent> startVideoCompression({
    required String id,
    required String path,
    required String destination,
    VideoSettings videoSettings = const VideoSettings(),
    bool skipAudio = false,
    AudioSettings audioSettings = const AudioSettings(),
    bool skipMetadata = false,
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
        'skipMetadata': skipMetadata,
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

  /// Compress audio file
  /// [id] - Unique process ID
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [settings] - Audio settings: codec, bitrate, sampleRate
  /// [skipMetadata] - Flag to skip source file metadata
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input audio file be deleted on succeed compression
  @override
  Stream<CompressionEvent> startAudioCompression({
    required String id,
    required String path,
    required String destination,
    AudioSettings settings = const AudioSettings(),
    bool skipMetadata = false,
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
        'skipMetadata': skipMetadata,
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

  /// Cancel current compression process
  @override
  Future<bool> cancelCompression(String id) async {
    // Cancel video compression process
    return await methodChannel
            .invokeMethod<bool>('cancelCompression', {'id': id}) ??
        false;
  }

  /// Convert image file
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [settings] - Image settings: format, quality, size
  /// [skipMetadata] - Flag to skip source file metadata
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input image file be deleted on succeed compression
  @override
  Future<ImageInfo?> imageCompression({
    required String path,
    required String destination,
    ImageSettings settings = const ImageSettings(),
    bool skipMetadata = false,
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async {
    // Run the image compression
    final data = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('imageCompression', {
      'path': path,
      'destination': destination,
      'settings': settings.toJson(),
      'skipMetadata': skipMetadata,
      'overwrite': overwrite,
      'deleteOrigin': deleteOrigin,
    });

    // Convert dict key from `Object?` to `String`
    final dict = data?.map((key, value) {
      return MapEntry<String, Object?>(
          key is String ? key : key.toString(), value);
    });

    return dict == null ? null : ImageInfo.fromJson(dict);
  }

  /// Extract thumbnails from video file
  /// [path] - Path location of input video file
  /// [requests] - Time points of thumbnails including destination path for each
  /// [settings] - Image settings: format, quality, size
  /// [transfrom] - A flag to apply preferred source video tranformations to thumbnail
  /// [timeToleranceBefore] - Time tolerance before specified time, in seconds
  /// [timeToleranceAfter] - Time tolerance after specified time, in seconds
  @override
  Future<List<VideoThumbnail>> videoThumbnails({
    required String path,
    required List<VideoThumbnailItem> requests,
    ImageSettings settings = const ImageSettings(),
    bool transfrom = true,
    double? timeToleranceBefore,
    double? timeToleranceAfter,
  }) async {
    // Execute thumbnail generation
    final entries =
        await methodChannel.invokeMethod<List<Object?>>('videoThumbnails', {
      'path': path,
      'requests': requests.map((r) => r.toJson()).toList(),
      'settings': settings.toJson(),
      'transfrom': transfrom,
      'timeToleranceBefore': timeToleranceBefore,
      'timeToleranceAfter': timeToleranceAfter,
    });

    // Process list of JSON objects
    return entries
            ?.map((entry) {
              if (entry == null) return null;

              // Convert Object? to Map<String, Object?>
              final data =
                  Map<String, Object?>.from(entry as Map<dynamic, dynamic>);

              // Serialize thumbnail file object
              return VideoThumbnail.fromJson(data);
            })
            // Skip empty results
            .whereType<VideoThumbnail>()
            .toList() ??
        [];
  }
}
