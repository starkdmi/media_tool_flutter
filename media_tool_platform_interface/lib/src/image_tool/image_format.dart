/// Available image formats
enum ImageFormat {
  /// HEIC (HEIF/HEIF10 with HEVC compression) image format
  /// Warning: Only Apple platforms supported
  heif,

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

  /// WebP image format
  /// Warning: Not supported on Apple platforms
  webp;

  /// Format identifier
  String get id {
    switch (this) {
      case ImageFormat.heif:
        return 'heif';
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
      case ImageFormat.webp:
        return 'webp';
    }
  }

  /// Init `ImageFormat` using format id
  static ImageFormat? fromId(String id) {
    try {
      return ImageFormat.values
          .firstWhere((e) => e.toString() == 'ImageFormat.$id');
    } catch (_) {
      return null;
    }
  }
}
