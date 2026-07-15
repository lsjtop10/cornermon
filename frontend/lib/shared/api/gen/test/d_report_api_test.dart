import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for DReportApi
void main() {
  final instance = CornermonApiGen().getDReportApi();

  group(DReportApi, () {
    // 현재 리포트 데이터 내보내기
    //
    // 현재 캠프 리포트를 다운로드한다.
    //
    //Future<CampReportResponse> campsCampIdReportsCurrentExportGet(String campId) async
    test('test campsCampIdReportsCurrentExportGet', () async {
      // TODO
    });

    // 현재 리포트 전체 조회
    //
    // 현재 활성화된 캠프의 상세 통계(CampReport)를 반환한다.
    //
    //Future<CampReportResponse> campsCampIdReportsCurrentGet(String campId) async
    test('test campsCampIdReportsCurrentGet', () async {
      // TODO
    });

    // 과거 리포트 생성 및 저장
    //
    // 캠프가 종료될 때 최종 리포트를 생성하여 저장소에 보관한다.
    //
    //Future<CampReportResponse> campsCampIdReportsGeneratePost(String campId) async
    test('test campsCampIdReportsGeneratePost', () async {
      // TODO
    });

    // 라이브 서머리 (대시보드 상단)
    //
    // 전체 진행 상황(완주율 등)의 핵심 요약 정보를 반환한다.
    //
    //Future<CampSummaryStatsResponse> campsCampIdReportsLiveSummaryGet(String campId) async
    test('test campsCampIdReportsLiveSummaryGet', () async {
      // TODO
    });

  });
}
