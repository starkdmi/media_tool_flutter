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
        const options = VideoCompressOptions(
          id: '10001',
          path: '/Users/starkdmi/Downloads/oludeniz.MOV',
          destination: '/Users/starkdmi/Downloads/oludeniz.compressed.mov',
          videoSettings: CompressVideoSettings(
            codec: CompressVideoCodec.hevc,
            bitrate: 2000000,
            // quality: 0.7,
            size: Size(1280, 1280),
          ),
          // audioSettings: null,
          audioSettings: CompressAudioSettings(
            codec: CompressAudioCodec.opus,
            bitrate: 96000,
            // sampleRate: 44100,
          ),
          overwrite: true,
          // deleteOrigin: false,
        );
        
        final task = VideoTool.compress(options);
        /*await for (final event in task.events) {
          print(event);
        }*/
        expect(task.events, emitsThrough(
          VideoCompressCompletedEvent(url: options.destination),
        ),);
      });
    });
  });
}
