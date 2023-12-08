part of 'media_tool_flutter.dart';

/// Image manipulation
class ImageTool {
  /// Compress image file
  static Future<ImageInfo?> compress({
    required String path,
    required String destination,
    ImageSettings settings = const ImageSettings(),
    bool skipMetadata = false,
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async {
    return _platform.imageCompression(
      path: path,
      destination: destination,
      settings: settings,
      skipMetadata: skipMetadata,
      overwrite: overwrite,
      deleteOrigin: deleteOrigin,
    );
  }

  /// Get image info
  static Future<ImageInfo?> info({required String path}) {
    return _platform.imageInfo(path: path);
  }
}
