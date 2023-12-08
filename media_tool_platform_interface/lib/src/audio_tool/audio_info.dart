import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

/// Audio info
class AudioInfo implements MediaInfo {
  /// Public initializer
  const AudioInfo({
    required this.url,
    required this.codec,
    required this.duration,
    this.bitrate,
  });

  /// File path
  @override
  final String url;

  /// Codec
  final AudioCodec? codec;

  /// Duration, in seconds
  final double duration;

  /// Bitrate, in bytes
  final int? bitrate;

  /// Initializer using JSON
  static AudioInfo? fromJson(Map<String, dynamic> data) {
    try {
      final path = data['path'] as String;

      final codecId = data['codec'] as int;
      final codec = AudioCodec.fromId(codecId);

      final duration = data['duration'] as num;
      final bitrate = data['bitrate'] as int?;

      return AudioInfo(
        url: path,
        codec: codec,
        duration: duration.toDouble(),
        bitrate: bitrate,
      );
    } catch (_) {
      return null;
    }
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'path': url,
        'codec': codec?.id,
        'duration': duration,
        'bitrate': bitrate,
      };

  /// Custom debug info
  @override
  String toString() => toJson().toString();
}
