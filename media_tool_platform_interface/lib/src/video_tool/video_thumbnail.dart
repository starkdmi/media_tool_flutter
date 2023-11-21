import 'dart:ui';
import 'package:media_tool_platform_interface/src/image_tool/image_format.dart';

/// Video thumbnail request
class VideoThumbnailItem {
  /// Public initializer
  const VideoThumbnailItem({ required this.time, required this.path });

  /// Time in seconds to capture thumbnail at
  final double time;

  /// Path where to save thumbnail at
  final String path;

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
    'time': time,
    'url': path,
  };
}

/// Video thumbnail file
class VideoThumbnail {
  /// Public initializer
  const VideoThumbnail({ required this.time, required this.path, this.format, this.size });

  /// Actual thubmnail time in seconds
  final double time;

  /// Thumbnail file path
  final String path;

  /// Image format
  final ImageFormat? format;

  /// Image resolution
  final Size? size;

  /// Serialize to JSON
  /*Map<String, dynamic> toJson() => {
    'time': time,
    'url': path,
    'format': format?.id,
    'width': size?.width,
    'height': size?.height,
  };*/

  /// Initializer using JSON
  static VideoThumbnail? fromJson(Map<String, dynamic> data) { // VideoThumbnail.fromJson(Map<String, dynamic> json): ... ;
    try {
      final time = data['time'] as double;
      final path = data['url'] as String;

      final formatId = data['format'] as String;
      final format = ImageFormat.fromId(formatId);

      final width = data['width'] as num;
      final height = data['height'] as num;
      final size = Size(width.toDouble(), height.toDouble());

      return VideoThumbnail(
        time: time, 
        path: path, 
        format: format,
        size: size,
      );
    } catch (_) {
      return null;
    }
  }
}
