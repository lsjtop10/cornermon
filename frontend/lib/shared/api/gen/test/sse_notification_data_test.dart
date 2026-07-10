import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

// tests for SseNotificationData
void main() {
  final instance = SseNotificationDataBuilder();
  // TODO add properties to the builder and call build()

  group(SseNotificationData, () {
    // 변경된 리소스의 범위. 클라이언트는 이 값만 보고 재조회할 REST 엔드포인트를 결정한다. - `camp` → 캠프 전역 리소스(코너/조/트랙 목록/캠프 상태/기기 등록 목록) - `track:{trackId}` → 특정 트랙의 상태 또는 메시지 스레드 - `broadcast` → 공지 채널 - `device:{deviceId}` → 특정 기기 등록 건 
    // String scope
    test('to test the property `scope`', () async {
      // TODO
    });

  });
}
