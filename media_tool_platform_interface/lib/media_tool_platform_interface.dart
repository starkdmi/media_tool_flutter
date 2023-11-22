import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
import 'package:media_tool_platform_interface/src/method_channel_media_tool.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:media_tool_platform_interface/src/audio_tool/audio_tool.dart';
export 'package:media_tool_platform_interface/src/image_tool/image_tool.dart';
export 'package:media_tool_platform_interface/src/video_tool/video_tool.dart';

/// The interface that implementations of media_tool_flutter must implement
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
  /// [skipMetadata] - Flag to skip source video metadata
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input video file be deleted on succeed compression
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
  });

  /// Compress audio file
  /// [id] - Unique process ID
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [settings] - Audio settings: codec, bitrate, sampleRate
  /// [skipMetadata] - Flag to skip source file metadata
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input audio file be deleted on succeed compression
  Stream<CompressionEvent> startAudioCompression({
    required String id,
    required String path,
    required String destination,
    AudioSettings settings = const AudioSettings(),
    bool skipMetadata = false,
    bool overwrite = false,
    bool deleteOrigin = false,
  });

  /// Cancel current compression process
  Future<bool> cancelCompression(String id);

  /// Convert image file
  /// [path] - Path location of input video file
  /// [destination] - Path location of output video file
  /// [settings] - Image settings: format, quality, size
  /// [skipMetadata] - Flag to skip source file metadata
  /// [overwrite] - Should overwrite exisiting file at destination
  /// [deleteOrigin] - Should input image file be deleted on succeed compression
  Future<ImageInfo?> imageCompression({
    required String path,
    required String destination,
    ImageSettings settings = const ImageSettings(),
    bool skipMetadata = false,
    bool overwrite = false,
    bool deleteOrigin = false,
  });

  /// Extract thumbnails from video file
  /// [path] - Path location of input video file
  /// [requests] - Time points of thumbnails including destination path for each
  /// [settings] - Image settings: format, quality, size
  /// [transfrom] - A flag to apply preferred source video tranformations to thumbnail
  /// [timeToleranceBefore] - Time tolerance before specified time, in seconds
  /// [timeToleranceAfter] - Time tolerance after specified time, in seconds
  Future<List<VideoThumbnail>> videoThumbnails({
    required String path,
    required List<VideoThumbnailItem> requests,
    ImageSettings settings = const ImageSettings(),
    bool transfrom = true,
    double? timeToleranceBefore,
    double? timeToleranceAfter,
  });
}
