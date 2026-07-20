import 'package:riverpod_annotation/riverpod_annotation.dart';

part '_track_bulk_manage_connection_state.g.dart';

/// 코너 삭제 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.
@riverpod
class TrackBulkManageConnectionLost extends _$TrackBulkManageConnectionLost {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}
