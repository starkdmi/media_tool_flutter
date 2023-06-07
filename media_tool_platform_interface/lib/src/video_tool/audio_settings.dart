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

/// Available Audio codecs
enum AudioCodec {
  /// AAC
  aac,

  /// Opus
  opus,

  /// FLAC
  flac
}

/// Audio codec extension
extension AudioCodecValue on AudioCodec {
  /// Audio codec id
  int get id {
    switch (this) {
    case AudioCodec.aac:
      return 1;
    case AudioCodec.opus:
      return 2;
    case AudioCodec.flac:
      return 3;
    }
  }
}
