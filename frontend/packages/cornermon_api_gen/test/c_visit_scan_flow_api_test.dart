import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for CVisitScanFlowApi
void main() {
  final instance = CornermonApiGen().getCVisitScanFlowApi();

  group(CVisitScanFlowApi, () {
    // 진행자 수동 체크인용 조 목록 조회
    //
    // 인증된 진행자의 트랙이 속한 캠프의 조 목록을 반환한다. 세션의 트랙과 path trackId가 일치해야 한다.
    //
    //Future<BuiltList<GroupResponse>> tracksTrackIdGroupsGet(String trackId) async
    test('test tracksTrackIdGroupsGet', () async {
      // TODO
    });

    // 현재 방문 종료 (조 퇴장)
    //
    // 진행 중인 방문을 종료 처리한다. (화면의 종료 확인 2회 탭)
    //
    //Future<VisitSummaryResponse> tracksTrackIdVisitsCurrentEndPost(String trackId) async
    test('test tracksTrackIdVisitsCurrentEndPost', () async {
      // TODO
    });

    // 현재 진행 중인 방문 상태 조회
    //
    // 스캐너 앱이 크래시되거나 새로고침 되었을 때, 현재 트랙에서 진행 중인 방문이 있는지 확인.
    //
    //Future<VisitSummaryResponse> tracksTrackIdVisitsCurrentGet(String trackId) async
    test('test tracksTrackIdVisitsCurrentGet', () async {
      // TODO
    });

    // 방문 시작 (조 입장)
    //
    // 진행자가 조의 입장을 처리한다. QR 스캔 또는 수동 처리.
    //
    //Future<VisitSummaryResponse> tracksTrackIdVisitsStartPost(String trackId, VisitStartRequest request) async
    test('test tracksTrackIdVisitsStartPost', () async {
      // TODO
    });

  });
}
