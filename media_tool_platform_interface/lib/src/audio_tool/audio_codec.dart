/// Available Audio codecs
enum AudioCodec {
  /// AAC
  aac,

  /// Opus
  opus,

  /// FLAC
  flac;

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

  /// Init `AudioCodec` using codec id
  static AudioCodec? fromId(int id) {
    try {
      return AudioCodec.values.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
