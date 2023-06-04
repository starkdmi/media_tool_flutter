part of 'media_tool.dart';

/// Video compression task 
class VideoCompressionTask {
  /// Constant constructor
  const VideoCompressionTask({ required this.id, required this.events });

  /// Unique process ID
  final String id;

  /// An events stream
  final Stream<VideoCompressEvent> events;

  /// Cancel current video compression process
  Future<bool> cancel() async {
    return _platform.cancelVideoCompression(id);
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
      overwrite: overwrite,
      deleteOrigin: deleteOrigin,
    );
    return VideoCompressionTask(id: id, events: stream);
  }
}
