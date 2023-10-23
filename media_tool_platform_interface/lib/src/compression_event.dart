/// Base class for video compression events
abstract class CompressionEvent { }

/// Video compression started event
class CompressionStartedEvent implements CompressionEvent { 
  /// Constant contructor
  const CompressionStartedEvent();
}

/// Event for progress in video compression 
class CompressionProgressEvent implements CompressionEvent { 
  /// Public initializer
  const CompressionProgressEvent({ required this.progress });

  /// Compression progress, [0.0, 1.0]
  final double progress;

  @override
  String toString() => '${super.toString()}, Progress: ${(progress * 100).toInt()}%';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
      other is CompressionProgressEvent && other.progress == progress;
  }

  @override
  int get hashCode => progress.hashCode;
}

/// Video compression completed event
class CompressionCompletedEvent implements CompressionEvent { 
  /// Public initializer
  const CompressionCompletedEvent({ required this.url });

  /// An url for output video file
  final String url;

  @override
  String toString() => '${super.toString()}, URL: $url';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
      other is CompressionCompletedEvent && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}

/// Video compression cancelled event
class CompressionCancelledEvent implements CompressionEvent { 
  /// Constant contructor
  const CompressionCancelledEvent();
}

/// Video compression failed event
class CompressionFailedEvent implements CompressionEvent {
  /// Public initializer
  const CompressionFailedEvent({ required this.error });

  /// An error in video compression process
  final String error;

  @override
  String toString() => '${super.toString()}, Error: $error';

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
      other is CompressionFailedEvent && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}
