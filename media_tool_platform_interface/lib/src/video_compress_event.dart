/// Base class for video compression events
abstract class VideoCompressEvent { }

/// Video compression started event
class VideoCompressStartedEvent implements VideoCompressEvent { }

/// Event for progress in video compression 
class VideoCompressProgressEvent implements VideoCompressEvent { 
  /// Public initializer
  const VideoCompressProgressEvent({ required this.progress });

  /// Compression progress, [0.0, 1.0]
  final double progress;
}

/// Video compression completed event
class VideoCompressCompletedEvent implements VideoCompressEvent { 
  /// Public initializer
  const VideoCompressCompletedEvent({ required this.url });

  /// An url for output video file
  final String url;
}

/// Video compression cancelled event
class VideoCompressCancelledEvent implements VideoCompressEvent { }

/// Video compression failed event
class VideoCompressFailedEvent implements VideoCompressEvent {
  /// Public initializer
  const VideoCompressFailedEvent({ required this.error });

  /// An error in video compression process
  final String error;
}
