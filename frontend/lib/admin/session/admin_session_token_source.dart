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
}
