import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_connection_state.g.dart';

/// 코너 추가/삭제가 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태 — `device_manage/state/device_manage_connection_state.dart`와
/// 동일한 패턴. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로
/// 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의 isConnectionLost 참고.
///
/// 앱 전역 SSE 연결 상태(재연결 중/끊김)는 이미 `admin/app.dart`가
/// `adminConnectionBannerStateProvider`로 모든 화면 위에 공통 배너를 띄우고 있다 —
/// 이 provider는 그것과 별개로, 이 화면의 코너 CRUD 액션 하나가 커넥션 유실로
/// 실패했을 때의 즉각적인 신호만 담당한다.
@riverpod
class DashboardConnectionLost extends _$DashboardConnectionLost {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}
