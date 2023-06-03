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
  static VideoCompressionTask compress(VideoCompressOptions options) {
    final stream = _platform.startVideoCompression(options);
    return VideoCompressionTask(id: options.id, events: stream);
  }
}
