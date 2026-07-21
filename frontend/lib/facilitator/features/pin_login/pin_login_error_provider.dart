import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

/// 429 PIN_LOCKED — 2분 단계, 카운트다운만 표시하고 액션 링크는 없다(도움요청 제거 결정, 2026-07-10).
class PinLocked extends PinLoginUiError {
  const PinLocked({required this.retryAfterSeconds});

  final int retryAfterSeconds;
}

/// 403 DEVICE_NOT_TRUSTED.
class DeviceNotTrustedYet extends PinLoginUiError {
  const DeviceNotTrustedYet();
}

/// 403 CAMP_NOT_ACTIVE.
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
      if (_isDeviceNotTrusted(e)) {
        await ref
            .read(deviceTrustProvider.notifier)
            .recoverFromTrackUnauthorized();
      }
      state = _mapError(e);
    }
  }

  bool _isDeviceNotTrusted(DioException e) =>
      e.response?.statusCode == 403 &&
      e.response?.data is Map &&
      (e.response?.data as Map)['code'] == 'DEVICE_NOT_TRUSTED';

  PinLoginUiError _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final body = data is Map ? data : null;
    final code = body?['code'] as String?;
    final details = body?['details'];
    final retryAfterSeconds = details is Map
        ? details['retryAfterSeconds'] as int?
        : null;

    if (statusCode == 400 && code == 'INVALID_PIN') {
      return PinInvalid(retryAfterSeconds: retryAfterSeconds);
    }
    if (statusCode == 403 && code == 'DEVICE_NOT_TRUSTED') {
      return const DeviceNotTrustedYet();
    }
    if (statusCode == 403 && code == 'CAMP_NOT_ACTIVE') {
      return const CampNotActiveYet();
    }
    if (statusCode == 429 && code == 'PIN_LOCKED') {
      return PinLocked(retryAfterSeconds: retryAfterSeconds ?? 0);
    }
    // 인식되지 않은 코드는 "PIN이 일치하지 않습니다"로 안전하게 대체한다(fail-safe degrade).
    return const PinInvalid();
  }
}
