import 'dart:async';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

/// An implementation of [MediaToolPlatform] that uses method channels
class MethodChannelMediaTool extends MediaToolPlatform {
  /// The method channel used to interact with the native platform
  @visibleForTesting
  final methodChannel = const MethodChannel('media_tool');

  @override
  Stream<VideoCompressEvent> startVideoCompression({
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
  Stream<VideoCompressEvent> startAudioCompression({
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
}
