/// Base class for media info objects
abstract class MediaInfo {
  /// Public initializer
  const MediaInfo({required this.url});

  /// An url for output media file
  final String url;
}
