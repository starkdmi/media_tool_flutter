import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool/media_tool.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMediaToolPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements MediaToolPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaTool', () {
    late MediaToolPlatform mediaToolPlatform;

    setUp(() {
      mediaToolPlatform = MockMediaToolPlatform();
      MediaToolPlatform.instance = mediaToolPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => mediaToolPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => mediaToolPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
