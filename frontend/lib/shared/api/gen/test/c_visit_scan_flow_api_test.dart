import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for CVisitScanFlowApi
void main() {
  final instance = CornermonApiGen().getCVisitScanFlowApi();

  group(CVisitScanFlowApi, () {
    // 특정 조의 전체 방문 이력
    //
    //Future<GroupsIdVisitsGet200Response> groupsIdVisitsGet(String id) async
    test('test groupsIdVisitsGet', () async {
      // TODO
    });

    // 현재 방문 종료 (조 퇴장)
    //
    // 진행 중인 방문을 종료 처리한다. (화면의 종료 확인 2회 탭) 재스캔 없이 트랙에 유일하게 정해진 IN_PROGRESS 방문을 종료한다. 소요시간 및 목표시간 편차(deviation)를 계산해 저장한다. 
    //
    //Future<VisitSummary> tracksTrackIdVisitsCurrentEndPost(String trackId) async
    test('test tracksTrackIdVisitsCurrentEndPost', () async {
      // TODO
    });

    // 현재 진행 중인 방문 조회
    //
    // 진행자 앱 화면 새로고침용. 현재 트랙에서 IN_PROGRESS 상태인 방문을 반환한다.
    //
    //Future<VisitSummary> tracksTrackIdVisitsCurrentGet(String trackId) async
    test('test tracksTrackIdVisitsCurrentGet', () async {
      // TODO
    });

    // 방문 시작 (조 입장)
    //
    // 진행자가 조의 입장을 처리한다. - **QR 스캔**: `qrToken` 제공 - **수동 처리**: `groupId` + `method: \"MANUAL\"` 제공 (QR 배지 손상 시)  **거부 조건**: - 트랙이 이미 BUSY (동시 진행 조 있음) - 해당 조가 이미 이 코너를 COMPLETED - 해당 조가 다른 코너에서 IN_PROGRESS 상태 
    //
    //Future<VisitSummary> tracksTrackIdVisitsStartPost(String trackId, TracksTrackIdVisitsStartPostRequest tracksTrackIdVisitsStartPostRequest) async
    test('test tracksTrackIdVisitsStartPost', () async {
      // TODO
    });

    // 중복 방문 예외 승인
    //
    // 중복 방문 금지 규칙의 예외를 관리자가 명시적으로 승인한다. 이후 해당 조의 해당 코너에서 재방문이 허용된다. 
    //
    //Future visitsExceptionApprovePost(VisitsExceptionApprovePostRequest visitsExceptionApprovePostRequest) async
    test('test visitsExceptionApprovePost', () async {
      // TODO
    });

  });
}
