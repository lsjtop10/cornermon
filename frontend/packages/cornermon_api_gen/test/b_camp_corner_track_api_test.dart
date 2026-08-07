import 'package:test/test.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';


/// tests for BCampCornerTrackApi
void main() {
  final instance = CornermonApiGen().getBCampCornerTrackApi();

  group(BCampCornerTrackApi, () {
    // 교체된 트랙의 세션 마이그레이션
    //
    // 트랙이 교체되어 `track_replaced` 알림을 받은 기기가 호출한다. 기존 세션 토큰을 Authorization 헤더에 담아 새 세션을 발급받는다.
    //
    //Future<TrackLoginResponse> tracksIdMigrateSessionPost(String id) async
    test('test tracksIdMigrateSessionPost', () async {
      // TODO
    });

  });
}
