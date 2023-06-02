import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool/media_tool.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaTool', () {
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

    group('Video Compression', () {
      test('simple', () async {
        const options = VideoCompressOptions(
          id: '10001',
          path: '/Users/starkdmi/Downloads/oludeniz.MOV',
          destination: '/Users/starkdmi/Downloads/oludeniz.compressed.mov',
        );
        
        final task = VideoTool.compress(options);
        /*await for (final event in task.events) {
          print(event);
        }*/
        expect(task.events, emitsThrough(
          const VideoCompressCompletedEvent(url: 'file:///Users/starkdmi/Downloads/oludeniz.compressed.mov'),
        ),);
      });
    });
  });
}
