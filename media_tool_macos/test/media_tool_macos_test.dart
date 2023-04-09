import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool_macos/media_tool_macos.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaToolMacOS', () {
    const kPlatformName = 'MacOS';
    late MediaToolMacOS mediaTool;
    late List<MethodCall> log;

    setUp(() async {
      mediaTool = MediaToolMacOS();

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
      MediaToolMacOS.registerWith();
      expect(MediaToolPlatform.instance, isA<MediaToolMacOS>());
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
