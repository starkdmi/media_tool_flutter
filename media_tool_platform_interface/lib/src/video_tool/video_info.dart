import 'dart:ui';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

/// Video info
class VideoInfo implements MediaInfo {
  /// Public initializer
  const VideoInfo({
    required this.url,
    required this.codec,
    required this.size,
    required this.frameRate,
    required this.duration,
    this.bitrate,
    this.hasAlpha = false,
    this.isHDR = false,
    this.hasAudio = false,
  });

  /// File path
  @override
  final String url;

  /// Codec
  final VideoCodec? codec;

  /// Resolution
  final Size size;

  /// Frame rate
  final int frameRate;

  /// Duration, in seconds
  final double duration;

  /// Bitrate, in bytes
  final int? bitrate;

  /// Alpha channel presence
  final bool hasAlpha;

  /// HDR data presence
  final bool isHDR;

  /// Audio presence
  final bool hasAudio;

  /// Initializer using JSON
  static VideoInfo? fromJson(Map<String, dynamic> data) {
    try {
      final path = data['path'] as String;

      final codecId = data['codec'] as String;
      final codec = VideoCodec.fromId(codecId);

      final width = data['width'] as num;
      final height = data['height'] as num;
      final size = Size(width.toDouble(), height.toDouble());

      final frameRate = data['frameRate'] as int;
      final duration = data['duration'] as num;
      final bitrate = data['bitrate'] as int?;

      final hasAlpha = data['hasAlpha'] as bool;
      final isHDR = data['isHDR'] as bool;
      final hasAudio = data['hasAudio'] as bool;

      return VideoInfo(
        url: path,
        codec: codec,
        size: size,
        frameRate: frameRate,
        duration: duration.toDouble(),
        bitrate: bitrate,
        hasAlpha: hasAlpha,
        isHDR: isHDR,
        hasAudio: hasAudio,
      );
    } catch (_) {
      return null;
    }
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'path': url,
        'codec': codec?.id,
        'width': size.width,
        'height': size.height,
        'hasAlpha': hasAlpha,
        'isHDR': isHDR,
        'hasAudio': hasAudio,
        'frameRate': frameRate,
        'duration': duration,
        'bitrate': bitrate,
      };

  /// Custom debug info
  @override
  String toString() => toJson().toString();
}
