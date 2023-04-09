import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool_ios/media_tool_ios.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaToolIOS', () {
    const kPlatformName = 'iOS';
    late MediaToolIOS mediaTool;
    late List<MethodCall> log;

    setUp(() async {
      mediaTool = MediaToolIOS();

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
      MediaToolIOS.registerWith();
      expect(MediaToolPlatform.instance, isA<MediaToolIOS>());
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
