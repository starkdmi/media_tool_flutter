import 'dart:ui';
import 'package:media_tool_platform_interface/src/image_tool/image_format.dart';

/// Image settings
class ImageSettings {
  /// Public initializer
  const ImageSettings({ 
    this.format,
    this.quality,
    this.size,
  });

  /// Image format
  final ImageFormat? format;

  /// Image compression rate, in range `[0.0, 1.0]` where `1.0` is original quality
  final double? quality;

  /// Image resolution to fit in
  final Size? size;

  /// Serialize to json
  Map<String, dynamic> toMap() => {
    'format': format?.id ?? '',
    'quality': quality ?? -1.0,
    'width': size?.width ?? -1.0,
    'height': size?.height ?? -1.0,
  };
}
