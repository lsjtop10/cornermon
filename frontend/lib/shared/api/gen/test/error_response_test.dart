import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

// tests for ErrorResponse
void main() {
  final instance = ErrorResponseBuilder();
  // TODO add properties to the builder and call build()

  group(ErrorResponse, () {
    // 에러 코드 (예: TRACK_BUSY, DUPLICATE_VISIT, DEVICE_NOT_TRUSTED)
    // String code
    test('to test the property `code`', () async {
      // TODO
    });

    // 사람이 읽을 수 있는 에러 설명
    // String message
    test('to test the property `message`', () async {
      // TODO
    });

    // 추가 컨텍스트 (선택적)
    // BuiltMap<String, JsonObject> details
    test('to test the property `details`', () async {
      // TODO
    });

  });
}
