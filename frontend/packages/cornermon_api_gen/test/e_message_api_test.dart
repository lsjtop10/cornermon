import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for EMessageApi
void main() {
  final instance = CornermonApiGen().getEMessageApi();

  group(EMessageApi, () {
    // 발송된 공지사항 목록
    //
    // 관리자가 보낸 BROADCAST 메시지들의 목록을 조회한다.
    //
    //Future<BuiltList<MessageResponse>> campsCampIdMessagesBroadcastGet(String campId) async
    test('test campsCampIdMessagesBroadcastGet', () async {
      // TODO
    });

    // 전체 공지 발송
    //
    // 모든 활성 트랙에 BROADCAST 메시지를 보낸다.
    //
    //Future<MessageResponse> campsCampIdMessagesBroadcastPost(String campId, BroadcastMessageRequest request) async
    test('test campsCampIdMessagesBroadcastPost', () async {
      // TODO
    });

    // 공지사항 읽음 처리
    //
    // 트랙 진행자가 공지사항을 확인(읽음) 처리한다.
    //
    //Future messagesBroadcastIdReadPost(String id) async
    test('test messagesBroadcastIdReadPost', () async {
      // TODO
    });

    // 공지사항 수신 확인 현황
    //
    // 특정 공지사항에 대해 트랙들의 수신/읽음 상태를 확인한다.
    //
    //Future<BuiltList<BroadcastReceiptResponse>> messagesBroadcastIdReceiptsGet(String id) async
    test('test messagesBroadcastIdReceiptsGet', () async {
      // TODO
    });

    // 트랙별 메시지 내역 조회 (진행자)
    //
    // 트랙 진행자가 자신의 트랙과 관련된 DIRECT 메시지 내역을 조회한다(GitHub Issue #69, 구현 예정).
    //
    //Future<BuiltList<MessageResponse>> tracksTrackIdMessagesGet(String trackId, { bool background, String after }) async
    test('test tracksTrackIdMessagesGet', () async {
      // TODO
    });

    // 다이렉트 메시지 발송
    //
    // 관리자가 특정 트랙에, 또는 특정 트랙이 관리자에게 DIRECT 메시지를 발송한다.
    //
    //Future<MessageResponse> tracksTrackIdMessagesPost(String trackId, DirectMessageRequest request) async
    test('test tracksTrackIdMessagesPost', () async {
      // TODO
    });

    // 트랙 미확인 다이렉트 메시지 개수 조회
    //
    // 호출자(관리자 또는 진행자) 기준으로 상대측이 보낸 미확인 메시지 개수를 반환한다(GitHub Issue #69, 구현 예정).
    //
    //Future<UnreadCountResponse> tracksTrackIdMessagesUnreadCountGet(String trackId) async
    test('test tracksTrackIdMessagesUnreadCountGet', () async {
      // TODO
    });

  });
}
