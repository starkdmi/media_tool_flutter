import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool_darwin/media_tool_darwin.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaToolDarwin', () {
    late MediaToolDarwin mediaTool;
    late List<MethodCall> log;

    setUp(() async {
      mediaTool = MediaToolDarwin();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mediaTool.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'startVideoCompression':
            return null;
          case 'startAudioCompression':
            return null;
          case 'cancelCompression':
            return null;
          case 'imageCompression':
            return null;
          case 'videoThumbnails':
            return null;
          case 'videoInfo':
            return null;
          case 'audioInfo':
            return null;
          case 'imageInfo':
            return null;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      MediaToolDarwin.registerWith();
      expect(MediaToolPlatform.instance, isA<MediaToolDarwin>());
    });

    /*test('getPlatformName returns correct name', () async {
      final name = await mediaTool.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });*/
  });
}
