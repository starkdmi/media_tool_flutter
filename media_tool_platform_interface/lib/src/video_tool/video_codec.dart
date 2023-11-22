/// Available video codecs
enum VideoCodec {
  /// H.264/AVC
  h264,

  /// H.265/HEVC
  h265,

  /// ProRes 4444, not all devices are supported
  prores;

  // muxa, jpeg, apcn, apch, apcs, apco

  /// Codec identifier
  String get id {
    switch (this) {
      case VideoCodec.h264:
        return 'avc1';
      case VideoCodec.h265:
        return 'hvc1';
      case VideoCodec.prores:
        return 'ap4h';
    }
  }
}
