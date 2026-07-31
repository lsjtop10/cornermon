import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for FEventsSSEApi
void main() {
  final instance = CornermonApiGen().getFEventsSSEApi();

  group(FEventsSSEApi, () {
    // Admin SSE Stream
    //
    // 관리자용 실시간 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\"event\":\"tracks_updated\",\"scope\":{\"kind\":\"camp\"}} 입니다. 이벤트에는 상태 스냅샷이 포함되지 않으므로, 수신한 클라이언트는 해당 REST API로 최신 상태를 조회해야 합니다. 이벤트는 best-effort 알림이므로 서버는 유실된 메시지를 저장·재전송하지 않습니다. 버퍼가 찬 연결은 종료되며, 클라이언트는 재연결 후 REST API로 최신 상태를 다시 조회해야 합니다.
    //
    //Future<SSENotification> apiV1CampsCampIdEventsAdminGet(String campId) async
    test('test apiV1CampsCampIdEventsAdminGet', () async {
      // TODO
    });

    // Track SSE Stream
    //
    // 트랙 진행자용 실시간 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\"event\":\"track_updated\",\"scope\":{\"kind\":\"track\",\"trackId\":\"track-id\"}} 입니다. 이벤트에는 상태 스냅샷이 포함되지 않으므로, 수신한 클라이언트는 해당 REST API로 최신 상태를 조회해야 합니다. 이벤트는 best-effort 알림이므로 서버는 유실된 메시지를 저장·재전송하지 않습니다. 버퍼가 찬 연결은 종료되며, 클라이언트는 재연결 후 REST API로 최신 상태를 다시 조회해야 합니다.
    //
    //Future<SSENotification> apiV1EventsTrackTrackIdGet(String trackId) async
    test('test apiV1EventsTrackTrackIdGet', () async {
      // TODO
    });

  });
}
