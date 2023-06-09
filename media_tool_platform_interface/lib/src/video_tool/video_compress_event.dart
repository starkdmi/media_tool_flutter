/// Base class for video compression events
abstract class VideoCompressEvent { }

/// Video compression started event
class VideoCompressStartedEvent implements VideoCompressEvent { 
  /// Constant contructor
  const VideoCompressStartedEvent();
}

/// Event for progress in video compression 
class VideoCompressProgressEvent implements VideoCompressEvent { 
  /// Public initializer
  const VideoCompressProgressEvent({ required this.progress });

  /// Compression progress, [0.0, 1.0]
  final double progress;

  @override
  String toString() => '${super.toString()}, Progress: ${(progress * 100).toInt()}%';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
      other is VideoCompressProgressEvent && other.progress == progress;
  }

  @override
  int get hashCode => progress.hashCode;
}

/// Video compression completed event
class VideoCompressCompletedEvent implements VideoCompressEvent { 
  /// Public initializer
  const VideoCompressCompletedEvent({ required this.url });

  /// An url for output video file
  final String url;

  @override
  String toString() => '${super.toString()}, URL: $url';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
      other is VideoCompressCompletedEvent && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}

/// Video compression cancelled event
class VideoCompressCancelledEvent implements VideoCompressEvent { 
  /// Constant contructor
  const VideoCompressCancelledEvent();
}

/// Video compression failed event
class VideoCompressFailedEvent implements VideoCompressEvent {
  /// Public initializer
  const VideoCompressFailedEvent({ required this.error });

  /// An error in video compression process
  final String error;

  @override
  String toString() => '${super.toString()}, Error: $error';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
      other is VideoCompressFailedEvent && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}
