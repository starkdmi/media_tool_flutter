import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

MediaToolPlatform get _platform => MediaToolPlatform.instance;

/// Returns the name of the current platform
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

/// Compress video file
Future<Stream<VideoCompressEvent>> startVideoCompression(VideoCompressOptions options) async {
  return _platform.startVideoCompression(options);
}

/// Cancel current video compression process
Future<bool> cancelVideoCompression(String id) async {
  return _platform.cancelVideoCompression(id);
}
