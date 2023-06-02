import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
export 'package:media_tool_platform_interface/media_tool_platform_interface.dart' show VideoCompressOptions;
export 'package:media_tool_platform_interface/media_tool_platform_interface.dart' show VideoCompressCancelledEvent, VideoCompressCompletedEvent, VideoCompressEvent, VideoCompressFailedEvent, VideoCompressProgressEvent, VideoCompressStartedEvent;

MediaToolPlatform get _platform => MediaToolPlatform.instance;

/// Returns the name of the current platform
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

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
