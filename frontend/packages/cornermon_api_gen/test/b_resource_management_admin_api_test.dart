import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for BResourceManagementAdminApi
void main() {
  final instance = CornermonApiGen().getBResourceManagementAdminApi();

  group(BResourceManagementAdminApi, () {
    // 초기 배지 일괄 생성
    //
    // 특정 개수만큼 QR 배지를 대량으로 일괄 발급한다.
    //
    //Future<BuiltList<BadgeResponse>> badgesBulkGeneratePost(BulkGenerateBadgesRequest request) async
    test('test badgesBulkGeneratePost', () async {
      // TODO
    });

    // QR 배지 인쇄용 목록 내보내기 (JSON)
    //
    // 클라이언트가 직접 PDF 인쇄 및 레이아웃 구성을 할 수 있도록 미배정(UNASSIGNED) 배지 전체 목록을 JSON으로 다운로드한다.
    //
    //Future<ExportBadgesResponse> badgesExportGet() async
    test('test badgesExportGet', () async {
      // TODO
    });

    // 전체 배지 목록 조회
    //
    // 시스템에 존재하는 전체 배지 목록을 조회한다.
    //
    //Future<BuiltList<BadgeResponse>> badgesGet() async
    test('test badgesGet', () async {
      // TODO
    });

    // 배지를 특정 조에 배정 (수동)
    //
    // 수동으로 특정 배지를 조회하여 조에 할당한다.
    //
    //Future<BadgeResponse> badgesIdRegisterPost(String id, AssignBadgeRequest request) async
    test('test badgesIdRegisterPost', () async {
      // TODO
    });

    // 배지를 특정 조에 배정 (스캔 기반)
    //
    // QR 코드를 스캔하여 배지를 특정 조에 등록(매핑)한다.
    //
    //Future<GroupResponse> badgesScanRegisterPost(ScanAssignBadgeRequest request) async
    test('test badgesScanRegisterPost', () async {
      // TODO
    });

    // 코너 목록 조회
    //
    // 특정 캠프의 모든 코너 목록을 조회한다.
    //
    //Future<BuiltList<CornerResponse>> campsCampIdCornersGet(String campId) async
    test('test campsCampIdCornersGet', () async {
      // TODO
    });

    // 전체 조 목록 조회
    //
    // 특정 캠프에 속한 모든 조의 목록과 상태를 조회한다.
    //
    //Future<BuiltList<GroupResponse>> campsCampIdGroupsGet(String campId) async
    test('test campsCampIdGroupsGet', () async {
      // TODO
    });

    // 트랙 목록 조회
    //
    // 전체 트랙 목록을 조회한다.
    //
    //Future<BuiltList<TrackResponse>> campsCampIdTracksGet(String campId) async
    test('test campsCampIdTracksGet', () async {
      // TODO
    });

    // 캠프 목록 조회
    //
    // 전체 캠프 목록을 조회한다.
    //
    //Future<BuiltList<CampResponse>> campsGet() async
    test('test campsGet', () async {
      // TODO
    });

    // 캠프 종료
    //
    // 캠프를 ENDED 상태로 변경한다. 이후 데이터 수정이 불가하다.
    //
    //Future<CampResponse> campsIdEndPost(String id) async
    test('test campsIdEndPost', () async {
      // TODO
    });

    // 캠프 상세 조회
    //
    // 특정 캠프 정보를 조회한다.
    //
    //Future<CampResponse> campsIdGet(String id) async
    test('test campsIdGet', () async {
      // TODO
    });

    // 캠프 정보 및 병목 기준 수정
    //
    // 캠프 이름, 예정 기간, 병목 판정 기준 중 요청에 포함된 필드만 수정한다. 종료된 캠프는 수정할 수 없다.
    //
    //Future<CampResponse> campsIdPatch(String id, UpdateCampRequest request) async
    test('test campsIdPatch', () async {
      // TODO
    });

    // 캠프 시작
    //
    // 캠프를 ACTIVE 상태로 변경하고 운영을 시작한다.
    //
    //Future<CampResponse> campsIdStartPost(String id) async
    test('test campsIdStartPost', () async {
      // TODO
    });

    // 새 캠프 생성
    //
    // 새로운 코너학습 캠프를 생성한다.
    //
    //Future<CampResponse> campsPost(CreateCampRequest request) async
    test('test campsPost', () async {
      // TODO
    });

    // 코너 대량 수정
    //
    // 여러 코너의 이름이나 목표 시간을 일괄 수정한다.
    //
    //Future<BuiltList<CornerResponse>> cornersBulkUpdatePut(BulkUpdateCornersRequest request) async
    test('test cornersBulkUpdatePut', () async {
      // TODO
    });

    // 코너별 트랙 목록 조회
    //
    // 특정 코너에 속한 트랙 목록을 조회한다.
    //
    //Future<BuiltList<TrackResponse>> cornersCornerIdTracksGet(String cornerId) async
    test('test cornersCornerIdTracksGet', () async {
      // TODO
    });

    // 코너 삭제
    //
    // 코너를 삭제한다. 단, 방문 기록이 있으면 삭제할 수 없다.
    //
    //Future cornersIdDelete(String id) async
    test('test cornersIdDelete', () async {
      // TODO
    });

    // 코너 상세 조회
    //
    // 특정 코너 정보를 조회한다.
    //
    //Future<CornerResponse> cornersIdGet(String id) async
    test('test cornersIdGet', () async {
      // TODO
    });

    // 새 코너 추가
    //
    // 캠프에 새로운 코너를 생성한다.
    //
    //Future<CornerResponse> cornersPost(CreateCornerRequest request) async
    test('test cornersPost', () async {
      // TODO
    });

    // 특정 조 상세 조회
    //
    // 특정 조의 현재 위치 및 순회표(Itinerary) 진행 상태를 조회한다.
    //
    //Future<GroupResponse> groupsIdGet(String id) async
    test('test groupsIdGet', () async {
      // TODO
    });

    // 조별 방문 기록 조회
    //
    // 특정 조의 전체 방문(Visit) 기록과 각 코너의 소요 시간 등을 조회한다.
    //
    //Future<BuiltList<VisitSummaryResponse>> groupsIdVisitsGet(String id) async
    test('test groupsIdVisitsGet', () async {
      // TODO
    });

    // 트랙 일괄 삭제
    //
    // 선택한 트랙들을 일괄 삭제한다.
    //
    //Future tracksBulkDeleteDelete(BulkDeleteTracksRequest request) async
    test('test tracksBulkDeleteDelete', () async {
      // TODO
    });

    // 트랙 인증 정보 전체 내보내기
    //
    // 인쇄를 위해 지정 캠프의 ACTIVE 트랙 PIN을 JSON으로 내려준다.
    //
    //Future<ExportTracksResponse> tracksExportGet(String campId) async
    test('test tracksExportGet', () async {
      // TODO
    });

    // 단일 트랙 인증 정보 내보내기
    //
    // 특정 트랙의 PIN을 JSON으로 내려준다.
    //
    //Future<TrackPinResponse> tracksIdExportGet(String id) async
    test('test tracksIdExportGet', () async {
      // TODO
    });

    // 트랙 상세 조회
    //
    // 트랙 상세 정보(PIN 등)를 조회한다.
    //
    //Future<TrackResponse> tracksIdGet(String id) async
    test('test tracksIdGet', () async {
      // TODO
    });

    // PIN 재발급
    //
    // 특정 트랙의 PIN 번호를 새로 생성한다.
    //
    //Future<TrackPinResponse> tracksIdRegeneratePinPost(String id) async
    test('test tracksIdRegeneratePinPost', () async {
      // TODO
    });

    // 트랙 교체 (비상용)
    //
    // 기존 트랙을 삭제하고 지정한 대상 코너에 새 트랙을 생성하며 기존 진행자 세션의 마이그레이션 대상을 설정한다.
    //
    //Future<TrackPinResponse> tracksIdReplacePut(String id, ReplaceTrackRequest request) async
    test('test tracksIdReplacePut', () async {
      // TODO
    });

    // 트랙 일괄 생성
    //
    // 특정 코너에 여러 트랙을 추가 생성한다.
    //
    //Future<BuiltList<TrackPinResponse>> tracksPost(CreateTracksRequest request) async
    test('test tracksPost', () async {
      // TODO
    });

  });
}
