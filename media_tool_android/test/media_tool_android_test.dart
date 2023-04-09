import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool_android/media_tool_android.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaToolAndroid', () {
    const kPlatformName = 'Android';
    late MediaToolAndroid mediaTool;
    late List<MethodCall> log;

    setUp(() async {
      mediaTool = MediaToolAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(mediaTool.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      MediaToolAndroid.registerWith();
      expect(MediaToolPlatform.instance, isA<MediaToolAndroid>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await mediaTool.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
