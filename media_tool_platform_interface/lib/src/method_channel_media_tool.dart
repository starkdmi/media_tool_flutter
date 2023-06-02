// ignore_for_file: lines_longer_than_80_chars
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
  Future<String?> getPlatformName() {
    throw UnimplementedError('getPlatformName() has not been implemented.');
  }

  @override
  Stream<VideoCompressEvent> startVideoCompression(VideoCompressOptions options) async* {
    throw UnimplementedError('startVideoCompression() has not been implemented.');
  }

  @override
  Future<bool> cancelVideoCompression(String id) async {
    throw UnimplementedError('cancelVideoCompression() has not been implemented.');
  }
}
