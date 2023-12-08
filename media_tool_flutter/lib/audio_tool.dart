part of 'media_tool_flutter.dart';

/// Audio manipulation
class AudioTool {
  /// Compress audio file
  static VideoCompressionTask compress({
    required String id,
    required String path,
    required String destination,
    AudioSettings settings = const AudioSettings(),
    bool skipMetadata = false,
    bool overwrite = false,
    bool deleteOrigin = false,
  }) {
    final stream = _platform.startAudioCompression(
      id: id,
      path: path,
      destination: destination,
      settings: settings,
      skipMetadata: skipMetadata,
      overwrite: overwrite,
      deleteOrigin: deleteOrigin,
    );
    return VideoCompressionTask(id: id, events: stream);
  }

  /// Get audio info
  static Future<AudioInfo?> info({required String path}) {
    return _platform.audioInfo(path: path);
  }
}
