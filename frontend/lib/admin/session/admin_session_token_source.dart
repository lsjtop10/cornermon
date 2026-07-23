import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/shared/auth/session_token_source.dart';

class AdminSessionTokenSource implements SessionTokenSource {
  AdminSessionTokenSource(this.ref);

  final Ref ref;

  @override
  String? get currentAccessToken =>
      ref.read(adminSessionProvider).accessTokenOrNull;

  @override
  Future<void> onUnauthorized() =>
      ref.read(adminSessionProvider.notifier).invalidate();

  @override
  Future<void> onSessionMigrationRequired() async {
    // 관리자 세션은 트랙 마이그레이션 대상이 될 수 없다(백엔드가 facilitatorSession에만
    // 게이트를 건다) — 도달할 일이 없는 분기라 no-op.
  }
}
