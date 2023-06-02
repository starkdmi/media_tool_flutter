/// Base class for video compression process settings
abstract class VideoCompressOptions {
  /// Public initializer
  const VideoCompressOptions({ required this.id, required this.path, required this.destination });

  /// Unique process ID
  final String id;

  /// Path location of input video file
  final String path;

  /// Path location of output video file
  final String destination;

  /// Convert class into Map object to pass over the MethodChannel
  Map<String, dynamic> toMap();
}
