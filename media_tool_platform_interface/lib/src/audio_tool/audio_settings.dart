import 'package:media_tool_platform_interface/src/audio_tool/audio_codec.dart';

/// Audio settings
class AudioSettings {
  /// Public initializer
  const AudioSettings({ 
    this.codec,
    this.bitrate,
    this.sampleRate,
  });

  /// Audio codec
  final AudioCodec? codec;

  /// Audio bitrate
  final int? bitrate;

  /// Sample rate
  final int? sampleRate;

  /// Serialize to json
  Map<String, dynamic> toMap() => {
    'codec': codec?.id ?? 0,
    'bitrate': bitrate ?? -1,
    'sampleRate': sampleRate ?? -1,
  };
}
