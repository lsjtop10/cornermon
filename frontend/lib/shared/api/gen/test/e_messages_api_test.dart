import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for EMessagesApi
void main() {
  final instance = CornermonApiGen().getEMessagesApi();

  group(EMessagesApi, () {
    // 공지 이력 조회
    //
    //Future<MessagesBroadcastGet200Response> messagesBroadcastGet({ int limit, DateTime before }) async
    test('test messagesBroadcastGet', () async {
      // TODO
    });

    // 공지 읽음 처리
    //
    // 해당 트랙이 공지를 읽음 처리한다.
    //
    //Future messagesBroadcastIdReadPost(String id) async
    test('test messagesBroadcastIdReadPost', () async {
      // TODO
    });

    // 공지별 트랙 읽음 현황
    //
    //Future<MessagesBroadcastIdReceiptsGet200Response> messagesBroadcastIdReceiptsGet(String id) async
    test('test messagesBroadcastIdReceiptsGet', () async {
      // TODO
    });

    // 전체 공지 발송
    //
    // 현재 ACTIVE 상태인 전체 트랙에 공지를 발송한다.
    //
    //Future<Message> messagesBroadcastPost(MessagesBroadcastPostRequest messagesBroadcastPostRequest) async
    test('test messagesBroadcastPost', () async {
      // TODO
    });

    // 트랙 다이렉트 메시지 이력
    //
    //Future<MessagesBroadcastGet200Response> tracksTrackIdMessagesGet(String trackId, { int limit, DateTime before }) async
    test('test tracksTrackIdMessagesGet', () async {
      // TODO
    });

    // 트랙 다이렉트 메시지 전송 (양방향)
    //
    // 관리자 → 트랙 또는 트랙 → 관리자 방향으로 다이렉트 메시지를 전송한다. - ADMIN: 어느 트랙에든 전송 가능 - TRACK: 자기 트랙 스레드에만 전송 가능 
    //
    //Future<Message> tracksTrackIdMessagesPost(String trackId, MessagesBroadcastPostRequest messagesBroadcastPostRequest) async
    test('test tracksTrackIdMessagesPost', () async {
      // TODO
    });

  });
}
