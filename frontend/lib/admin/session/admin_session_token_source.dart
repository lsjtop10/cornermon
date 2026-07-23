import 'package:dio/dio.dart';
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

  /// 관리자 앱은 트랙 스코프 개념이 없어 404를 특별 취급하지 않는다(이슈 #200은 진행자 전용).
  @override
  Future<bool> onResourceNotFound(DioException error) async => false;
}
