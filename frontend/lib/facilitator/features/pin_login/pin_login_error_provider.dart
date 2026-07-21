import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/api/dio_error.dart';
import '../../session/device_trust_provider.dart';
import '../../session/track_session_provider.dart';

part 'pin_login_error_provider.g.dart';

/// B1 로그인 실패 응답의 ErrorResponse.code에 따른 화면 반응 — 서버가 유일한 판단 주체이고
/// 클라이언트는 카운트를 따로 세지 않는다(§domain-model 3.4).
sealed class PinLoginUiError {
  const PinLoginUiError();
}

/// 400 INVALID_PIN.
class PinInvalid extends PinLoginUiError {
  const PinInvalid({this.retryAfterSeconds});

  /// 있으면 점증형 지연 카운트다운(5초/30초 단계)을 함께 표시한다.
  final int? retryAfterSeconds;
}

/// 429 DEVICE_LOCKED — 2분 단계, 카운트다운만 표시하고 액션 링크는 없다(도움요청 제거 결정, 2026-07-10).
class PinLocked extends PinLoginUiError {
  const PinLocked({required this.retryAfterSeconds});

  final int retryAfterSeconds;
}

/// 403 DEVICE_NOT_APPROVED.
class DeviceNotTrustedYet extends PinLoginUiError {
  const DeviceNotTrustedYet();
}

/// 403 CAMP_NOT_AVAILABLE.
class CampNotActiveYet extends PinLoginUiError {
  const CampNotActiveYet();
}

@riverpod
class PinLoginError extends _$PinLoginError {
  @override
  PinLoginUiError? build() => null;

  Future<void> submit(String pin) async {
    try {
      await ref.read(trackSessionProvider.notifier).loginWithPin(pin);
      state = null;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final code = errorCodeOf(e);
      if (statusCode == 403 && code == ErrorCode.CodeDeviceNotApproved) {
        await ref
            .read(deviceTrustProvider.notifier)
            .recoverFromTrackUnauthorized();
      }
      state = _mapError(statusCode, code, e);
    }
  }

  PinLoginUiError _mapError(int? statusCode, ErrorCode? code, DioException e) {
    final data = e.response?.data;
    final body = data is Map ? data : null;
    final details = body?['details'];
    final retryAfterSeconds = details is Map
        ? details['retryAfterSeconds'] as int?
        : null;

    if (statusCode == 400 && code == ErrorCode.CodeInvalidPin) {
      return PinInvalid(retryAfterSeconds: retryAfterSeconds);
    }
    if (statusCode == 403 && code == ErrorCode.CodeDeviceNotApproved) {
      return const DeviceNotTrustedYet();
    }
    if (statusCode == 403 && code == ErrorCode.CodeCampNotAvailable) {
      return const CampNotActiveYet();
    }
    if (statusCode == 429 && code == ErrorCode.CodeDeviceLocked) {
      return PinLocked(retryAfterSeconds: retryAfterSeconds ?? 0);
    }
    // 인식되지 않은 코드는 "PIN이 일치하지 않습니다"로 안전하게 대체한다(fail-safe degrade).
    return const PinInvalid();
  }
}
