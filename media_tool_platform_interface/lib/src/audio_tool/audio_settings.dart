import 'package:media_tool_platform_interface/src/audio_tool/audio_codec.dart';
import 'package:media_tool_platform_interface/src/audio_tool/audio_quality.dart';

/// Audio settings
class AudioSettings {
  /// Public initializer
  const AudioSettings({ 
    this.codec,
    this.bitrate,
    this.sampleRate,
    this.quality,
  });

  /// Audio codec
  final AudioCodec? codec;

  /// Audio bitrate
  final int? bitrate;

  /// Sample rate
  final int? sampleRate;

  /// Audio quality, AAC and FLAC only
  final AudioQuality? quality;

  /// Serialize to json
  Map<String, dynamic> toMap() => {
    'codec': codec?.id ?? 0,
    'bitrate': bitrate ?? -1,
    'sampleRate': sampleRate ?? -1,
    'quality': quality?.value ?? -1,
  };
}
