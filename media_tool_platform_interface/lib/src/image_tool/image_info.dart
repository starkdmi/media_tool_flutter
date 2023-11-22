import 'dart:ui';
import 'package:media_tool_platform_interface/src/image_tool/image_format.dart';

/// Image info
class ImageInfo {
  /// Public initializer
  const ImageInfo({
    required this.format,
    required this.size,
    this.hasAlpha = false,
    this.isHDR = false,
    this.isAnimated = false,
    this.orientation = 1,
    this.frameRate,
    this.duration,
  });

  /// Image format
  final ImageFormat format;

  /// Image resolution
  final Size size;

  /// Alpha channel presence
  final bool hasAlpha;

  /// HDR data presence
  final bool isHDR;

  /// Animation presence
  final bool isAnimated;

  // Image frames amount, one for static images
  // final int framesCount;

  /// Image orientation
  final int orientation;

  /// Animated image frame rate
  final int? frameRate;

  /// Animated image duration
  final double? duration;

  /// Initializer using JSON
  static ImageInfo? fromJson(Map<String, dynamic> data) {
    // ImageInfo.fromJson(Map<String, dynamic> json): ... ;
    try {
      final formatId = data['format'] as String;
      final format = ImageFormat.fromId(formatId);

      final width = data['width'] as num;
      final height = data['height'] as num;
      final size = Size(width.toDouble(), height.toDouble());

      final hasAlpha = data['hasAlpha'] as bool;
      final isHDR = data['isHDR'] as bool;
      final isAnimated = data['isAnimated'] as bool;
      final orientation = data['orientation'] as int;
      final frameRate = data['frameRate'] as int?;
      final duration = data['duration'] as double?;

      return ImageInfo(
        format: format!,
        size: size,
        hasAlpha: hasAlpha,
        isHDR: isHDR,
        isAnimated: isAnimated,
        orientation: orientation,
        frameRate: frameRate,
        duration: duration,
      );
    } catch (_) {
      return null;
    }
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'format': format.id,
        'width': size.width,
        'height': size.height,
        'hasAlpha': hasAlpha,
        'isHDR': isHDR,
        'isAnimated': isAnimated,
        'orientation': orientation,
        'frameRate': frameRate,
        'duration': duration,
      };

  /// Custom debug info
  @override
  String toString() => toJson().toString();
}
