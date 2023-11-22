/// Audio quality enumeration
enum AudioQuality {
  /// AVAudioQuality.min == 0
  min,

  /// AVAudioQuality.low == 32
  low,

  /// AVAudioQuality.medium == 64
  medium,

  /// AVAudioQuality.high == 96
  high,

  /// AVAudioQuality.max == 127
  max
}

/// Audio quality extension
extension AudioQualityValue on AudioQuality {
  /// Corresponding integer value
  int get value {
    switch (this) {
      case AudioQuality.min:
        return 0;
      case AudioQuality.low:
        return 32;
      case AudioQuality.medium:
        return 64;
      case AudioQuality.high:
        return 96;
      case AudioQuality.max:
        return 127;
    }
  }
}
