import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

/// Base class for video/audio compression events
abstract class CompressionEvent {
  /// Public initializer
  const CompressionEvent({this.custom});

  /// Optional custom field
  final dynamic custom;
}

/// Video/Audio compression started event
class CompressionStartedEvent implements CompressionEvent {
  /// Constant contructor
  const CompressionStartedEvent({this.custom});

  /// Optional custom field
  @override
  final dynamic custom;
}

/// Event for progress in video/audio compression
class CompressionProgressEvent implements CompressionEvent {
  /// Public initializer
  const CompressionProgressEvent({required this.progress, this.custom});

  /// Compression progress, [0.0, 1.0]
  final double progress;

  /// Optional custom field
  @override
  final dynamic custom;

  @override
  String toString() =>
      '${super.toString()}, Progress: ${(progress * 100).toInt()}%';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CompressionProgressEvent && other.progress == progress;
  }

  @override
  int get hashCode => progress.hashCode;
}

/// Video/Audio compression completed event
class CompressionCompletedEvent implements CompressionEvent {
  /// Public initializer
  const CompressionCompletedEvent({required this.info, this.custom});

  /// Output media information
  final MediaInfo info;

  /// Optional custom field
  @override
  final dynamic custom;

  @override
  String toString() => '${super.toString()}, Info: $info';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CompressionCompletedEvent && other.info.url == info.url;
  }

  @override
  int get hashCode => info.url.hashCode;
}

/// Video/Audio compression cancelled event
class CompressionCancelledEvent implements CompressionEvent {
  /// Constant contructor
  const CompressionCancelledEvent({this.custom});

  /// Optional custom field
  @override
  final dynamic custom;
}

/// Video/Audio compression failed event
class CompressionFailedEvent implements CompressionEvent {
  /// Public initializer
  const CompressionFailedEvent({required this.error, this.custom});

  /// An error in video/audio compression process
  final String error;

  /// Optional custom field
  @override
  final dynamic custom;

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
