/// Base class for video compression process settings
abstract class VideoCompressOptions {
  /// Public initializer
  const VideoCompressOptions({ required this.path, required this.destination });

  /// Path location of input video file
  final String path;

  /// Path location of output video file
  final String destination;

  /// Convert class into Map object to pass over the MethodChannel
  Map<String, dynamic> toMap();
}

/// Darwin implementation of [VideoCompressOptions]
class VideoCompressOptionsDarwin extends VideoCompressOptions {
  /// Public initializer
  const VideoCompressOptionsDarwin({ 
    required super.path, 
    required super.destination, 
    required this.x,
  }) : super();

  /// Some property
  final int x;

  /// Generate Map object to pass over the MethodChannel
  @override
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'destination': destination,
      'x' : x 
    };
  }
}
