/*import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool_platform_interface/src/method_channel_media_tool.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelMediaTool', () {
    late MethodChannelMediaTool methodChannelMediaTool;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelMediaTool = MethodChannelMediaTool()
        ..methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformName':
              return kPlatformName;
            default:
              return null;
          }
        });
    });

    tearDown(log.clear);

    test('getPlatformName', () async {
      final platformName = await methodChannelMediaTool.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(platformName, equals(kPlatformName));
    });
  });
}*/
