import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:media_tool_flutter/media_tool_flutter.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
// import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MediaTool', () {
    final directory = (goldenFileComparator as LocalFileComparator).basedir.path;
    print(MediaToolPlatform.instance.runtimeType);

    group('VideoTool', () {
      test('compress single', () async {
        final file = File('${directory}media/oludeniz.MOV');
        final path = await copyToTmp(file, 'oludeniz.MOV');
        final destination = '${directory}temp/oludeniz_compressed.mov';

        final task = VideoTool.compress(
          id: '10001',
          path: path, // '$directory/media/oludeniz.MOV',
          destination: destination,
          videoSettings: const VideoSettings(
            codec: VideoCodec.h265,
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
          CompressionCompletedEvent(info: MockInfo(url: destination)),
        ),);
        print(destination);
      });

      test('progress & cancellation', () async {
        final task = VideoTool.compress(
          id: '10002',
          path: '$directory/media/oludeniz.MOV',
          destination: '${directory}temp/oludeniz_h264.mp4',
          videoSettings: const VideoSettings(codec: VideoCodec.h264),
          skipAudio: true,
          overwrite: true,
        );

        Future.delayed(const Duration(milliseconds: 750), () async {
          await task.cancel();
        });

        /*expect(task.events, emitsInOrder(const [
          VideoCompressStartedEvent(),
          VideoCompressProgressEvent(progress: 0.1),
          VideoCompressProgressEvent(progress: 0.25),
          VideoCompressCancelledEvent(),
        ]),);*/

        expect(task.events, emitsThrough(
          const CompressionCancelledEvent(),
        ),);
      });

      test('generate video thumbnails', () async {
        // TODO: Swift fails to save files running under Flutter
        final file = File('$directory/media/bigbuckbunny.mp4'); // oludeniz.MOV
        final path = await copyToTmp(file, 'bigbuckbunny.mp4');
        final destination = '${directory}temp/thumbnails';
        // final temp = await getTemporaryDirectory();
        // final appDir = await getApplicationDocumentsDirectory();

        final thumbnails = await VideoTool.thumbnails(
          path: path,
          requests: [
            // VideoThumbnailItem(time: 0.5, path: '/Users/starkdmi/Downloads/thumb_0_5.png'),
            // VideoThumbnailItem(time: 1.0, path: '/tmp/media_tool_test/thumb_1_0.png'),
            VideoThumbnailItem(time: 1.5, path: '$destination/thumb_1_5.png'),
          ],
          settings: const ImageSettings(
            format: ImageFormat.png,
          ),
        );
        print(destination);
        expect(thumbnails, isNotEmpty);
      });
    });

    group('AudioTool', () {
      test('compress single', () async {
        // Copy nasa_on_a_mission.mp3 to temp directory for tests
        final file = File('$directory/media/nasa_on_a_mission.mp3');
        final path = await copyToTmp(file, 'nasa_on_a_mission.mp3');
        final destination = '${directory}temp/nasa_on_a_mission.m4a';

        final task = AudioTool.compress(
          id: '20001',
          path: path,
          destination: destination,
          settings: const AudioSettings(
            codec: AudioCodec.flac,
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
          CompressionCompletedEvent(info: MockInfo(url: destination)),
        ),);
        print(destination);
      });
    });

    group('ImageTool', () {
      test('compress single', () async {
        // Copy cat.jpg to temp directory for tests
        final file = File('$directory/media/cat.jpg');
        final path = await copyToTmp(file, 'cat.jpg');
        final destination = '${directory}temp/cat.png';

        final info = await ImageTool.compress(
          path: path,
          destination: destination,
          settings: const ImageSettings(
            format: ImageFormat.png,
            quality: 0.95,
            size: Size(256, 256),
            crop: true,
            frameRate: 30,
            skipAnimation: true,
            preserveAlphaChannel: false,
            embedThumbnail: true,
            optimizeColors: true,
            backgroundColor: Color(0xFFFF9000),
          ),
          overwrite: true,
          // deleteOrigin: true,
        );
        print(info);

        expect(info?.format, equals(ImageFormat.png));

        print(destination);
      });
    });
  });
}

/// Mocked info
class MockInfo implements MediaInfo {
  /// Public initializer
  const MockInfo({ required this.url });

  /// File path
  @override
  final String url;
}

/// Copy media file to custom directory at `/tmp`
Future<String> copyToTmp(File source, String filename) async {
  /* To resolve the issue: `The file "oludeniz.MOV" couldn’t be opened because you don’t have permission to view it.` the App Sandbox was turned off using Xcode */
  final temp = Directory('/tmp/media_tool_test');
  // final tmp = await getTemporaryDirectory();
  // final temp = await tmp.createTemp('media_tool_test');
  if (!temp.existsSync()) {
    await temp.create(recursive: true);
  }
  final path = '${temp.path}/$filename';
  if (!File(path).existsSync()) {
    await source.copy(path);
  }
  return path;
}
