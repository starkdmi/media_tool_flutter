import 'dart:async';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
import 'package:media_tool_platform_interface/src/video_tool/video_thumbnail.dart';

/// An implementation of [MediaToolPlatform] that uses method channels
class MethodChannelMediaTool extends MediaToolPlatform {
  /// The method channel used to interact with the native platform
  @visibleForTesting
  final methodChannel = const MethodChannel('media_tool');

  @override
  Stream<CompressionEvent> startVideoCompression({
    required String id,
    required String path,
    required String destination,
    VideoSettings videoSettings = const VideoSettings(),
    bool skipAudio = false,
    AudioSettings audioSettings = const AudioSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async* {
    throw UnimplementedError('startVideoCompression() has not been implemented.');
  }

  @override
  Stream<CompressionEvent> startAudioCompression({
    required String id,
    required String path,
    required String destination,
    AudioSettings settings = const AudioSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async* {
    throw UnimplementedError('startAudioCompression() has not been implemented.');
  }

  @override
  Future<bool> cancelCompression(String id) async {
    throw UnimplementedError('cancelCompression() has not been implemented.');
  }

  @override
  Future<ImageInfo?> imageCompression({
    required String path,
    required String destination,
    ImageSettings settings = const ImageSettings(),
    bool overwrite = false,
    bool deleteOrigin = false,
  }) async {
    throw UnimplementedError('imageCompression() has not been implemented.');
  }

  /*@override
  Future<List<VideoThumbnail>> videoThumbnails({
    required String path,
    required List<VideoThumbnailItem> requests,
    ImageSettings settings = const ImageSettings(),
    bool transfrom = true,
    double? timeToleranceBefore,
    double? timeToleranceAfter,
  }) async {
    throw UnimplementedError('videoThumbnails() has not been implemented.');
  }*/
}
