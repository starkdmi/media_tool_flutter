import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool/media_tool.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getPlatformName', () {
    test('returns correct name when platform implementation exists', () async {
      String platformName;
      if (Platform.isIOS) {
        platformName = 'iOS';
      } else if (Platform.isMacOS) {
        platformName = 'MacOS';
      } else {
        throw UnimplementedError();
      }

      final actualPlatformName = await getPlatformName();
      expect(actualPlatformName, equals(platformName));
    });
  });

  group('MediaTool', () {
    group('VideoTool', () {
      test('compression single', () async {
        final task = VideoTool.compress(
          id: '10001',
          path: '/Users/starkdmi/Downloads/oludeniz.MOV',
          destination: '/Users/starkdmi/Downloads/oludeniz.compressed.mov',
          videoSettings: const VideoSettings(
            codec: VideoCodec.hevc,
            bitrate: 2000000,
            // quality: 0.7,
            size: Size(1280, 1280),
          ),
          // skipAudio: false,
          audioSettings: const AudioSettings(
            codec: AudioCodec.opus,
            bitrate: 96000,
            // sampleRate: 44100,
          ),
          overwrite: true,
          // deleteOrigin: false,
        );
        /*await for (final event in task.events) {
          print(event);
        }*/
        expect(task.events, emitsThrough(
          const VideoCompressCompletedEvent(url: '/Users/starkdmi/Downloads/oludeniz.compressed.mov'),
        ),);
      });
    });
  });
}
