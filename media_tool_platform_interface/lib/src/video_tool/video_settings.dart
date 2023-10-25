import 'dart:ui';
import 'package:media_tool_platform_interface/src/video_tool/video_codec.dart';

/// Video settings
class VideoSettings {
  /// Public initializer
  const VideoSettings({ 
    this.codec,
    this.bitrate,
    this.quality,
    this.size,
    this.frameRate,
    this.preserveAlphaChannel = true,
    this.disableHardwareAcceleration = false,
  });

  /// Video codec
  final VideoCodec? codec;

  /// Video bitrate
  final int? bitrate;

  /// Video quality, in range `[0.0, 1.0]`, ignored when `bitrate` is set
  final double? quality;

  /// Video resolution to fit in
  final Size? size;

  /// Video frame rate
  final int? frameRate;

  /// A flag to preserve alpha channel in video
  final bool preserveAlphaChannel;

  /// A flag to disable video hardware acceleration
  final bool disableHardwareAcceleration;

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
    'codec': codec?.id,
    'bitrate': bitrate,
    'quality': quality,
    'width': size?.width,
    'height': size?.height,
    'frameRate': frameRate,
    'keepAlpha': preserveAlphaChannel,
    'hardwareAcceleration': !disableHardwareAcceleration,
  };
}
