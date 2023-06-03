import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
export 'package:media_tool_platform_interface/media_tool_platform_interface.dart' show CompressAudioCodec, CompressAudioSettings, CompressVideoCodec, CompressVideoSettings, VideoCompressOptions;
export 'package:media_tool_platform_interface/media_tool_platform_interface.dart' show VideoCompressCancelledEvent, VideoCompressCompletedEvent, VideoCompressEvent, VideoCompressFailedEvent, VideoCompressProgressEvent, VideoCompressStartedEvent;

part 'video_tool.dart';

MediaToolPlatform get _platform => MediaToolPlatform.instance;

/// Returns the name of the current platform
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}
