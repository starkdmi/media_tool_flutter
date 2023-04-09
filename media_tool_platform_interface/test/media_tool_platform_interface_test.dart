import 'package:flutter_test/flutter_test.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';

class MediaToolMock extends MediaToolPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MediaToolPlatformInterface', () {
    late MediaToolPlatform mediaToolPlatform;

    setUp(() {
      mediaToolPlatform = MediaToolMock();
      MediaToolPlatform.instance = mediaToolPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await MediaToolPlatform.instance.getPlatformName(),
          equals(MediaToolMock.mockPlatformName),
        );
      });
    });
  });
}
