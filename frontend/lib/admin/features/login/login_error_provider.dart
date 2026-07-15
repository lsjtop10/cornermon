import 'package:dio/dio.dart';
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
  const AdminLoginServerError();
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
    } on DioException catch (error) {
      state = error.response?.statusCode == 401
          ? const AdminLoginInvalidCredentials()
          : const AdminLoginServerError();
      rethrow;
    } catch (_) {
      state = const AdminLoginServerError();
      rethrow;
    }
  }
}
