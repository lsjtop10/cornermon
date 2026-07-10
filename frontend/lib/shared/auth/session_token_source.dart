import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_token_source.g.dart';

/// AuthInterceptor가 의존하는 DI 경계(00_overview.md §4-a).
/// shared 계층은 구현을 모른다 — main_admin.dart/main_facilitator.dart(합성 지점)가
/// ProviderScope(overrides:)로 앱별 구현체(AdminSessionTokenSource/TrackSessionTokenSource)를 주입한다.
abstract interface class SessionTokenSource {
  String? get currentAccessToken;

  /// 401 수신 시 처리를 각 앱의 세션 로직에 위임한다.
  /// 관리자: silent refresh, 진행자: 세션 강제종료.
  Future<void> onUnauthorized();
}

@riverpod
SessionTokenSource sessionTokenSource(Ref ref) =>
    throw UnimplementedError('main_admin.dart 또는 main_facilitator.dart에서 반드시 override');
