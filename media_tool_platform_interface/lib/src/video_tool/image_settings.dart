import 'dart:ui';

/// Image settings
class ImageSettings {
  /// Public initializer
  const ImageSettings({ 
    this.format,
    this.quality,
    this.size,
  });

  /// Image format
  final ImageFormat? format;

  /// Image compression rate, in range `[0.0, 1.0]` where `1.0` is original quality
  final double? quality;

  /// Image resolution to fit in
  final Size? size;

  /// Serialize to json
  Map<String, dynamic> toMap() => {
    'format': format?.id ?? '',
    'quality': quality ?? -1.0,
    'width': size?.width ?? -1.0,
    'height': size?.height ?? -1.0,
  };
}

/// Available image formats
enum ImageFormat {
  // HEIC (HEIF/HEIF10 with HEVC compression) image format
  // heif,

  /// JPEG image format
  jpeg,

  /// PNG image format, with support of animated images (APNG)
  png,

  /// GIF image format
  gif,

  /// Tag Image File Format
  tiff,

  /// Bitmap image format
  bmp,

  // WebP image format
  // webp,
}

/// Image format extension
extension ImageFormatValue on ImageFormat {
  /// Format identifier
  String get id {
    switch (this) {
    // case ImageFormat.heif:
    //   return 'heif';
    case ImageFormat.jpeg:
      return 'jpeg';
    case ImageFormat.png:
      return 'png';
    case ImageFormat.gif:
      return 'gif';
    case ImageFormat.tiff:
      return 'tiff';
    case ImageFormat.bmp:
      return 'bmp';
    // case ImageFormat.webp:
    //   return 'webp';
    }
  }

  /// Init `ImageFormat` using format id
  static ImageFormat? fromId(String id) {
    try {
      return ImageFormat.values.firstWhere((e) => e.toString() == 'ImageFormat.$id');
    } catch (_) {
      return null;
    }
  }
}
