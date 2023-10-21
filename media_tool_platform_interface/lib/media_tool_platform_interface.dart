import 'package:media_tool_platform_interface/src/method_channel_media_tool.dart';
import 'package:media_tool_platform_interface/src/video_tool/video_tool.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:media_tool_platform_interface/src/video_tool/video_tool.dart';

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

  /// Compress video file
  /// [id] - Unique process ID
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [videoSettings] - Video settings: codec, bitrate, quality, resolution
  /// [skipAudio] - If `true` then audio is skipped
  /// [audioSettings] - Audio settings: codec, bitrate, sampleRate
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input video file be deleted on succeed compression
  Stream<VideoCompressEvent> startVideoCompression({
    required String id,
    required String path,
    required String destination,
    VideoSettings videoSettings = const VideoSettings(),
    bool skipAudio = false,
    AudioSettings audioSettings = const AudioSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  });

  /// Compress audio file
  /// [id] - Unique process ID
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [settings] - Audio settings: codec, bitrate, sampleRate
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input video file be deleted on succeed compression
  Stream<VideoCompressEvent> startAudioCompression({
    required String id,
    required String path,
    required String destination,
    AudioSettings settings = const AudioSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  });

  /// Cancel current compression process
  Future<bool> cancelCompression(String id);
}
