import 'dart:ui';

/// Base class for video compression settings
class VideoCompressOptions {
  /// Public initializer
  const VideoCompressOptions({ 
    required this.id, 
    required this.path, 
    required this.destination,
    this.videoSettings = const CompressVideoSettings(),
    this.audioSettings = const CompressAudioSettings(),
    this.overwrite = false,
    this.deleteOrigin = false,
  });

  /// Unique process ID
  final String id;

  /// Path location of input video file
  final String path;

  /// Path location of output video file
  final String destination;

  /// Video settings
  final CompressVideoSettings videoSettings; // codec, bitrate, quality, size/resolution, +-frameRate

  /// Audio settings, if `nil` then audio is skipped
  final CompressAudioSettings? audioSettings; // codec, bitrate, quality, sampleRate

  /// Should overwrite exisiting file at destination
  final bool overwrite;

  /// Should input video file be deleted on succeed compression
  final bool deleteOrigin;

  /// Convert class into Map object to pass over the MethodChannel
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'destination': destination,
      'video': videoSettings.toMap(),
      'audio': audioSettings?.toMap(),
      'overwrite': overwrite,
      'deleteOrigin': deleteOrigin,
    };
  }
}

/// Video settings
class CompressVideoSettings {
  /// Public initializer
  const CompressVideoSettings({ 
    this.codec,
    this.bitrate,
    this.quality,
    this.size,
  });

  /// Video codec
  final CompressVideoCodec? codec;

  /// Video bitrate
  final int? bitrate;

  /// Video quality, in range `[0.0, 1.0]`, ignored when `bitrate` is set
  final double? quality;

  /// Video resolution to fit in
  final Size? size;

  /// Serialize to json
  Map<String, dynamic> toMap() => {
    'codec': codec?.id,
    'bitrate': bitrate,
    'quality': quality,
    'width': size?.width,
    'height': size?.height,
  };
}

/// Available video codecs
enum CompressVideoCodec {
  /// H.264
  h264,

  /// H.265/HEVC
  hevc,

  /// ProRes 4444
  prores

  // muxa, jpeg, apcn, apch, apcs, apco
}

/// Video codec extension
extension CompressVideoCodecValue on CompressVideoCodec {
  /// Codec identifier
  String get id {
    switch (this) {
    case CompressVideoCodec.h264:
      return 'avc1';
    case CompressVideoCodec.hevc:
      return 'hvc1';
    case CompressVideoCodec.prores:
      return 'ap4h';
    }
  }
}

/// Audio settings
class CompressAudioSettings {
  /// Public initializer
  const CompressAudioSettings({ 
    this.codec,
    this.bitrate,
    this.sampleRate,
  });

  /// Audio codec
  final CompressAudioCodec? codec;

  /// Audio bitrate
  final int? bitrate;

  /// Sample rate
  final int? sampleRate;

  /// Serialize to json
  Map<String, dynamic> toMap() => {
    'codec': codec?.id,
    'bitrate': bitrate,
    'sampleRate': sampleRate,
  };
}

/// Available Audio codecs
enum CompressAudioCodec {
  /// AAC
  aac,

  /// Opus
  opus,

  /// FLAC
  flac
}

/// Audio codec extension
extension CompressAudioCodecValue on CompressAudioCodec {
  /// Audio codec id
  int get id {
    switch (this) {
    case CompressAudioCodec.aac:
      return 1;
    case CompressAudioCodec.opus:
      return 2;
    case CompressAudioCodec.flac:
      return 3;
    }
  }
}
