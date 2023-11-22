part of 'media_tool_flutter.dart';

/// Video compression task
class VideoCompressionTask {
  /// Constant constructor
  const VideoCompressionTask({required this.id, required this.events});

  /// Unique process ID
  final String id;

  /// An events stream
  final Stream<CompressionEvent> events;

  /// Cancel current video compression process
  Future<bool> cancel() async {
    return _platform.cancelCompression(id);
  }
}

/// Video manipulation
class VideoTool {
  /// Compress video file
  static VideoCompressionTask compress({
    required String id,
    required String path,
    required String destination,
    VideoSettings videoSettings = const VideoSettings(),
    bool skipAudio = false,
    AudioSettings audioSettings = const AudioSettings(),
    bool skipMetadata = false,
    bool overwrite = false,
    bool deleteOrigin = false,
  }) {
    final stream = _platform.startVideoCompression(
      id: id,
      path: path,
      destination: destination,
      videoSettings: videoSettings,
      skipAudio: skipAudio,
      audioSettings: audioSettings,
      skipMetadata: skipMetadata,
      overwrite: overwrite,
      deleteOrigin: deleteOrigin,
    );
    return VideoCompressionTask(id: id, events: stream);
  }

  /// Generate video thumbnails
  static Future<List<VideoThumbnail>> videoThumbnails({
    required String path,
    required List<VideoThumbnailItem> requests,
    ImageSettings settings = const ImageSettings(),
    bool transfrom = true,
    double? timeToleranceBefore,
    double? timeToleranceAfter,
  }) {
    return _platform.videoThumbnails(
      path: path,
      requests: requests,
      settings: settings,
      transfrom: transfrom,
      timeToleranceBefore: timeToleranceBefore,
      timeToleranceAfter: timeToleranceAfter,
    );
  }
}
