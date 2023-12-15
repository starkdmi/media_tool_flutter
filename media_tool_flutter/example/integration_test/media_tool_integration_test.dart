import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:media_tool_ffmpeg/media_tool_ffmpeg.dart' as ffmpeg;
import 'package:media_tool_flutter/media_tool_flutter.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
import 'package:video_compress/video_compress.dart' as video_compress;

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

      test('benchmarks', () async {

        // H.264, MP4, 720 x 1280 (macOS)
        // media_tool_darwin 1.085888, 0.881570, 0.890366
        // media_tool_ffmpeg 8.180939, 8.402862
        // light_compressor 1.261467, 1.226514 (file not checked)
        // video_compress 0.924311 (bitrate is ~8K)

        // H.264, MP4, 1080x1920 (macOS)
        // media_tool_darwin 1.608758, 1.631405
        // media_tool_ffmpeg 18.995048, 18.762380 (bitrate is ~4K)
        // light_compressor 2.874317, 2.886106 (file not checked)
        // video_compress 1.440795, 1.548949, 1.502010 (bitrate is ~10K)

        final file = File('${directory}media/oludeniz.MOV');
        final path = await copyToTmp(file, 'oludeniz.MOV');

        const videoSettings = VideoSettings(
          codec: VideoCodec.h264,
          bitrate: 2000000,
          // quality: 0.7,
          size: Size(1920, 1920), // Size(1280, 1280)
        );
        const audioSettings = AudioSettings(codec: AudioCodec.aac);

        var stopwatch = Stopwatch()..start();
        final task = VideoTool.compress(
          id: '10001',
          path: path,
          destination: '${directory}temp/oludeniz_compressed_media_tool_darwin.mp4',
          videoSettings: videoSettings,
          audioSettings: audioSettings,
          overwrite: true,
        );
        /*await for (final event in task.events) {
          print(event);
        }*/
        await task.events.last;
        print('media_tool_darwin executed in ${stopwatch. elapsed}');

        stopwatch = Stopwatch()..start();
        final stream = ffmpeg.MediaToolFFmpeg().startVideoCompression(
          id: '10001',
          path: path,
          destination: '${directory}temp/oludeniz_compressed_media_tool_ffmpeg.mp4',
          videoSettings: videoSettings,
          audioSettings: audioSettings,
          overwrite: true,
        );
        /*await for (final event in stream) {
          print(event);
        }*/
        await stream.last;
        print('media_tool_ffmpeg executed in ${stopwatch. elapsed}');

        stopwatch = Stopwatch()..start();
        final lightCompressor = LightCompressor();
        final response = await lightCompressor.compressVideo(
          path: path,
          videoQuality: VideoQuality.medium, // ignored when bitrate is set
          isMinBitrateCheckEnabled: false,
          video: Video(
            videoName: 'oludeniz_compressed_light_compressor.mp4',
            // keepOriginalResolution: false,
            videoBitrateInMbps: 2, // videoSettings.bitrate! ~/ 1000000,
            videoHeight: 1920,
            videoWidth: 1080,
          ),
          android: AndroidConfig(),
          ios: IOSConfig(saveInGallery: true),
        );
        print(response);
        print('light_compressor executed in ${stopwatch. elapsed}');

        stopwatch = Stopwatch()..start();
        final mediaInfo = await video_compress.VideoCompress.compressVideo(
          path,
          quality: video_compress.VideoQuality.Res1920x1080Quality, // Res1280x720Quality, Res1920x1080Quality
          includeAudio: true,
        );
        print(mediaInfo?.path);
        print('video_compress executed in ${stopwatch. elapsed}');
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
      test('benchmarks', () async {

        // PNG 512x683 (macOS)
        // imaged 00.7078 - 2x slower than ffmpeg
        // darwin 00.0805 - 5x faster than ffmpeg
        // ffmpeg 00.3754
        // PNG 768x1024 (macOS)
        // imaged 00.8956
        // darwin 00.0911
        // ffmpeg 00.3179
        // JPEG 768x1024 (macOS)
        // imaged 00.7065, 894KB
        // darwin 00.0927, 325KB, 00.0302 on second and third call
        // ffmpeg 00.3359, 86KB, 00.3126 on second and third call

        const filename = 'cat.jpg';
        const destination = 'cat.png';
        final file = File('$directory/media/$filename');
        final path = await copyToTmp(file, filename);  

        const settings = ImageSettings(
          format: ImageFormat.png,
          // quality: 0.95,
          size: Size(1024, 1024),
          // preserveAlphaChannel: false,
        );
        final size = settings.size;

        // await Future.delayed(const Duration(seconds: 1));

        int? width;
        int? height;
        if (size != null) {
          if (size.width >= size.height) {
            height = size.height.toInt();
          } else {
            width = size.width.toInt();
          }
        }
        var stopwatch = Stopwatch()..start();
        final cmd = img.Command()
          ..decodeImageFile(path)
          ..copyResize(width: width, height: height, interpolation: img.Interpolation.nearest) // cubic
          ..writeToFile('${directory}temp/image_dart_package_$destination');
        await cmd.executeThread();
        // await compute((_) => cmd.executeThread(), null);
        print('image_dart_package executed in ${stopwatch. elapsed}');

        stopwatch = Stopwatch()..start();
        await ImageTool.compress(
          path: path,
          destination: '${directory}temp/media_tool_darwin_$destination',
          settings: settings,
          overwrite: true,
        );
        print('media_tool_darwin executed in ${stopwatch. elapsed}');

        stopwatch = Stopwatch()..start();
        await ffmpeg.MediaToolFFmpeg().imageCompression(
          path: path,
          destination: '${directory}temp/media_tool_ffmpeg_$destination',
          settings: settings,
          overwrite: true,
        );
        print('media_tool_ffmpeg executed in ${stopwatch. elapsed}');
      });

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
