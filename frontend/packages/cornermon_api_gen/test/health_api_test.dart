import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for HealthApi
void main() {
  final instance = CornermonApiGen().getHealthApi();

  group(HealthApi, () {
    // 헬스체크
    //
    // 서버가 정상적으로 응답하는지 확인한다. 인증이 필요하지 않다.
    //
    //Future<HealthResponse> healthGet() async
    test('test healthGet', () async {
      // TODO
    });

    // 레디니스 체크
    //
    // 서버가 데이터베이스 등 필수 의존성에 연결되어 트래픽을 받을 준비가 되었는지 확인한다. 인증이 필요하지 않다.
    //
    //Future<HealthResponse> readyGet() async
    test('test readyGet', () async {
      // TODO
    });

  });
}
