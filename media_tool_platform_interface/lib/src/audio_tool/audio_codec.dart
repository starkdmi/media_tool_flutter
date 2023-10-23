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