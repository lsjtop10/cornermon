import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/admin/session/admin_session_provider.dart';

part 'login_error_provider.g.dart';

sealed class AdminLoginUiError {
  const AdminLoginUiError();
}

class AdminLoginInvalidCredentials extends AdminLoginUiError {
  const AdminLoginInvalidCredentials();
}

class AdminLoginServerError extends AdminLoginUiError {
  const AdminLoginServerError([this.debugDetail]);
  final String? debugDetail;
}

/// 로그인 화면에만 필요한 일시적인 오류 상태다.
@riverpod
class LoginError extends _$LoginError {
  @override
  AdminLoginUiError? build() => null;

  Future<void> submit(String loginId, String password) async {
    state = null;
    try {
      await ref.read(adminSessionProvider.notifier).login(loginId, password);
    } on DioException catch (error, stackTrace) {
      final detail =
          'DioException type=${error.type} statusCode=${error.response?.statusCode} '
          'message=${error.message} error=${error.error}';
      debugPrint('[login] $detail\n$stackTrace');
      state = error.response?.statusCode == 401
          ? const AdminLoginInvalidCredentials()
          : AdminLoginServerError(detail);
      rethrow;
    } catch (error, stackTrace) {
      final detail = '${error.runtimeType} $error';
      debugPrint('[login] non-Dio error $detail\n$stackTrace');
      state = AdminLoginServerError(detail);
      rethrow;
    }
  }
}
