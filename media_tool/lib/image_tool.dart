part of 'media_tool.dart';

/// Image manipulation
class ImageTool {
  /// Compress image file
  static Future<ImageInfo?> compress({
    required String path,
    required String destination,
    ImageSettings settings = const ImageSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async {
    return _platform.imageCompression(
      path: path,
      destination: destination,
      settings: settings,
      overwrite: overwrite,
      deleteOrigin: deleteOrigin,
    );
  }
}
