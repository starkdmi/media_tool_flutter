import 'dart:ui';

/// Video settings
class VideoSettings {
  /// Public initializer
  const VideoSettings({ 
    this.codec,
    this.bitrate,
    this.quality,
    this.size,
  });

  /// Video codec
  final VideoCodec? codec;

  /// Video bitrate
  final int? bitrate;

  /// Video quality, in range `[0.0, 1.0]`, ignored when `bitrate` is set
  final double? quality;

  /// Video resolution to fit in
  final Size? size;

  /// Serialize to json
  Map<String, dynamic> toMap() => {
    'codec': codec?.id ?? '',
    'bitrate': bitrate ?? -1,
    'quality': quality ?? -1.0,
    'width': size?.width ?? -1.0,
    'height': size?.height ?? -1.0,
  };
}

/// Available video codecs
enum VideoCodec {
  /// H.264
  h264,

  /// H.265/HEVC
  h265,

  /// ProRes 4444, not all devices are supported
  prores

  // muxa, jpeg, apcn, apch, apcs, apco
}

/// Video codec extension
extension VideoCodecValue on VideoCodec {
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
