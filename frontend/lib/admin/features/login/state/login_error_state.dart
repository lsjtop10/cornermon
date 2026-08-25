import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/logging/app_logger.dart';

part 'login_error_state.g.dart';

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
    } on DioException catch (error) {
      // DioException은 LoggingInterceptor(#131)가 네트워크 계층에서 이미 기록한다.
      final detail = describeDioError(error);
      state = error.response?.statusCode == 401
          ? const AdminLoginInvalidCredentials()
          : AdminLoginServerError(detail);
      rethrow;
    } catch (error, stackTrace) {
      final detail = '${error.runtimeType} $error';
      ref
          .read(appLoggerProvider)
          .error('login', 'non-Dio error', error: error, stackTrace: stackTrace);
      state = AdminLoginServerError(detail);
      rethrow;
    }
  }
}
