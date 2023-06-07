import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_tool/media_tool.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MediaTool', () {
    final directory = (goldenFileComparator as LocalFileComparator).basedir.path;

    group('VideoTool', () {
      test('compress single', () async {
        final task = VideoTool.compress(
          id: '10001',
          path: '$directory/media/oludeniz.MOV',
          destination: '$directory/temp/oludeniz_compressed.mov',
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
          // deleteOrigin: true,
        );
        /*await for (final event in task.events) {
          print(event);
        }*/
        expect(task.events, emitsThrough(
          VideoCompressCompletedEvent(url: '$directory/temp/oludeniz_compressed.mov'),
        ),);
      });

      test('progress & cancellation', () async {
        final task = VideoTool.compress(
          id: '10002',
          // path: '/Users/starkdmi/Downloads/oludeniz.MOV',
          // destination: '/Users/starkdmi/Downloads/oludeniz_h264.mp4',
          path: '$directory/media/oludeniz.MOV',
          destination: '$directory/temp/oludeniz_h264.mp4',
          videoSettings: const VideoSettings(codec: VideoCodec.h264),
          skipAudio: true,
          overwrite: true,
        );

        Future.delayed(const Duration(milliseconds: 1250), () async {
          await task.cancel();
        });

        /*expect(task.events, emitsInOrder(const [
          VideoCompressStartedEvent(),
          VideoCompressProgressEvent(progress: 0.1),
          VideoCompressProgressEvent(progress: 0.25),
          VideoCompressCancelledEvent(),
        ]),);*/

        expect(task.events, emitsThrough(
          const VideoCompressCancelledEvent(),
        ),);
      });
    });
  });
}
