import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool/media_tool.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaTool', () {
    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = 'iOS';

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });
    });
  });
}