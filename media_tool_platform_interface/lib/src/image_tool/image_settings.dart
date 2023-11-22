import 'dart:ui';
import 'package:media_tool_platform_interface/src/image_tool/image_format.dart';

/// Image settings
class ImageSettings {
  /// Public initializer
  const ImageSettings({
    this.format,
    this.quality,
    this.size,
    this.crop = false,
    this.frameRate,
    this.skipAnimation = false,
    this.preserveAlphaChannel = true,
    this.embedThumbnail = false,
    this.optimizeColors = false,
    this.backgroundColor,
  });

  /// Image format
  final ImageFormat? format;

  /// Image compression rate, in range `[0.0, 1.0]` where `1.0` is original quality
  final double? quality;

  /// Image resolution to fit in
  final Size? size;

  /// Crop, when set image will be cropped to [size] instead of fitting
  final bool crop;

  /// Animated image frame rate
  final int? frameRate;

  /// A flag to skip animation data (to use primary frame only)
  final bool skipAnimation;

  /// A flag to preserve alpha channel in animated image sequence
  final bool preserveAlphaChannel;

  /// A flag used for thumbnail embeding
  final bool embedThumbnail;

  /// A flag to use most compatible colors
  final bool optimizeColors;

  /// Background color
  /// Used when [preserveAlphaChannel] is set to `false` or alpha channel is not supported by output image format
  final Color? backgroundColor;

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'format': format?.id,
        'quality': quality,
        'width': size?.width,
        'height': size?.height,
        'crop': crop,
        'frameRate': frameRate,
        'skipAnimation': skipAnimation,
        'keepAlpha': preserveAlphaChannel,
        'embedThumbnail': embedThumbnail,
        'optimizeColors': optimizeColors,
        'backgroundColor': backgroundColor?.value,
      };
}
