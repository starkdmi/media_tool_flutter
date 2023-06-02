// ignore_for_file: lines_longer_than_80_chars
import 'package:media_tool_platform_interface/src/method_channel_media_tool.dart';
import 'package:media_tool_platform_interface/src/video_compress_event.dart';
import 'package:media_tool_platform_interface/src/video_compress_options.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:media_tool_platform_interface/src/video_compress_event.dart';
export 'package:media_tool_platform_interface/src/video_compress_options.dart';

/// The interface that implementations of media_tool must implement
///
/// Platform implementations should extend this class
/// rather than implement it as `MediaTool`
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [MediaToolPlatform] methods
abstract class MediaToolPlatform extends PlatformInterface {
  /// Constructs a MediaToolPlatform
  MediaToolPlatform() : super(token: _token);

  static final Object _token = Object();

  static MediaToolPlatform _instance = MethodChannelMediaTool();

  /// The default instance of [MediaToolPlatform] to use
  ///
  /// Defaults to [MethodChannelMediaTool]
  static MediaToolPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MediaToolPlatform] when they register themselves
  static set instance(MediaToolPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name
  Future<String?> getPlatformName();

  /// Compress video file
  Stream<VideoCompressEvent> startVideoCompression(VideoCompressOptions options);

  /// Cancel current video compression process
  Future<bool> cancelVideoCompression(String id);
}
