import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool/media_tool.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaTool', () {
    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        String platformName;
        if (Platform.isIOS) {
          platformName = 'iOS';
        } else if (Platform.isMacOS) {
          platformName = 'MacOS';
        } else {
          throw UnimplementedError();
        }

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });
    });
  });
}
