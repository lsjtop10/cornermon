import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for GAuditLogsApi
void main() {
  final instance = CornermonApiGen().getGAuditLogsApi();

  group(GAuditLogsApi, () {
    // 감사 로그 조회
    //
    // 인증 성공/실패, 스캔, 규칙 변경, 기기 승인/철회, 트랙 관리 등의 감사 로그를 조회한다. 메시지 통신 내역은 감사 대상에서 제외. 필터링·정렬을 쿼리 파라미터로 지정해 서버에서 처리한다. 
    //
    //Future<AuditLogsGet200Response> auditLogsGet({ String actor, String action, String result, String sort, String order, int limit, DateTime before }) async
    test('test auditLogsGet', () async {
      // TODO
    });

  });
}
