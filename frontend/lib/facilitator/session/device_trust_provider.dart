import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';

part 'device_trust_provider.g.dart';

/// #107에서 확인된 기본값. 승인 대기 화면이 떠 있는 동안만 폴링하므로 서버 부하가
/// 크지 않다 — 화면 전환/앱 백그라운드 시 ref.onDispose로 반드시 취소된다.
const _pollInterval = Duration(seconds: 15);

/// §2.4-b. `none`은 아직 등록 요청을 보낸 적 없는 클라이언트 로컬 상태이고,
/// 나머지 4개는 [DeviceRegistrationStatus](서버)를 그대로 미러링한다.
enum DeviceTrustStatus { none, pending, approved, rejected, revoked }

/// 트랙 인증 401 뒤 `/device-registrations/me`의 권위 있는 상태로 내린 결론이다.
/// `retained`는 PIN 세션만 만료됐다는 뜻이고, `cleared`는 이 기기의 등록도 더 이상
/// 쓸 수 없다는 뜻이다. 네트워크·형식 오류는 등록을 섣불리 지우지 않고 `unresolved`로
/// 남겨 다음 보호 API 실패에서 다시 판정한다.
enum DeviceTrustRecovery { retained, cleared, unresolved }

const _deviceRegistrationIdKey = 'device_trust_registration_id';
const _deviceStatusKey = 'device_trust_status';
const _deviceTrustTokenKey = 'device_trust_token';

DeviceTrustStatus _fromApiStatus(DeviceRegistrationCreatedStatus status) =>
    switch (status) {
      DeviceRegistrationCreatedStatus.PENDING => DeviceTrustStatus.pending,
      DeviceRegistrationCreatedStatus.APPROVED => DeviceTrustStatus.approved,
      DeviceRegistrationCreatedStatus.REJECTED => DeviceTrustStatus.rejected,
      DeviceRegistrationCreatedStatus.REVOKED => DeviceTrustStatus.revoked,
      _ => DeviceTrustStatus.none,
    };

DeviceTrustStatus _fromStatusResponse(DeviceStatusStatus status) =>
    switch (status) {
      DeviceStatusStatus.PENDING => DeviceTrustStatus.pending,
      DeviceStatusStatus.APPROVED => DeviceTrustStatus.approved,
      DeviceStatusStatus.REJECTED => DeviceTrustStatus.rejected,
      DeviceStatusStatus.REVOKED => DeviceTrustStatus.revoked,
      _ => DeviceTrustStatus.none,
    };

@riverpod
class DeviceTrust extends _$DeviceTrust {
  Timer? _pollTimer;
  Future<DeviceTrustRecovery>? _recoveryInFlight;

  @override
  Future<DeviceTrustStatus> build() async {
    ref.onDispose(() => _pollTimer?.cancel());

    final store = ref.watch(secureTokenStoreProvider);
    final statusName = await store.read(_deviceStatusKey);
    final status = DeviceTrustStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => DeviceTrustStatus.none,
    );
    if (status == DeviceTrustStatus.pending) {
      _schedulePolling();
    }
    return status;
  }

  /// PENDING → APPROVED/REJECTED/REVOKED 전이를 GET /device-registrations/me
  /// 폴링으로 감지한다(#107 확인, #109 스코프 밖으로 미뤄졌던 부분). 전이가
  /// 감지되면 타이머를 멈추고 상태를 갱신 — 라우터의 refreshListenable이 이를 보고
  /// 자동으로 화면을 전환한다.
  void _schedulePolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    final store = ref.read(secureTokenStoreProvider);
    final deviceToken = await store.read(_deviceTrustTokenKey);
    if (deviceToken == null) {
      _pollTimer?.cancel();
      return;
    }

    try {
      final api = ref.read(authDeviceTrustApiProvider);
      final response = await api.deviceRegistrationsMeGet(
        xDeviceToken: deviceToken,
      );
      final responseStatus = response.data?.status;
      if (responseStatus == null) return;

      final newStatus = _fromStatusResponse(responseStatus);
      if (newStatus == DeviceTrustStatus.pending) return;

      if (newStatus == DeviceTrustStatus.revoked) {
        await clearRegistration();
        return;
      }

      _pollTimer?.cancel();
      await store.write(_deviceStatusKey, newStatus.name);
      state = AsyncData(newStatus);
    } on DioException catch (error, stackTrace) {
      // 일시적 네트워크 오류로 폴링 자체를 멈추지 않는다 — 다음 tick에 재시도.
      debugPrint(
        '[device_trust] polling failed: type=${error.type} '
        'statusCode=${error.response?.statusCode}\n$stackTrace',
      );
    }
  }

  /// 트랙 권한이 401로 거절됐을 때 기기 토큰으로 최종 원인을 확인한다.
  ///
  /// SSE의 종류·도착 순서는 판단 근거가 아니다. `APPROVED + ACTIVE`면 PIN 세션만
  /// 끝난 것이므로 기기 등록을 보존하고, `REVOKED + ENDED` 및 `REVOKED + 그 외`
  /// 상태면 [clearRegistration]으로 등록까지 폐기한다. 동시에 여러 보호 REST가 401을
  /// 받아도 상태 조회는 하나만 수행한다.
  Future<DeviceTrustRecovery> recoverFromTrackUnauthorized() {
    return _recoveryInFlight ??= _recoverFromTrackUnauthorized().whenComplete(
      () => _recoveryInFlight = null,
    );
  }

  Future<DeviceTrustRecovery> _recoverFromTrackUnauthorized() async {
    final store = ref.read(secureTokenStoreProvider);
    final deviceToken = await store.read(_deviceTrustTokenKey);
    if (deviceToken == null) return DeviceTrustRecovery.unresolved;

    try {
      final response = await ref
          .read(authDeviceTrustApiProvider)
          .deviceRegistrationsMeGet(xDeviceToken: deviceToken);
      final registration = response.data;
      final registrationStatus = registration?.status;
      final campStatus = registration?.campStatus;
      if (registrationStatus == null || campStatus == null) {
        return DeviceTrustRecovery.unresolved;
      }

      if (registrationStatus == DeviceStatusStatus.APPROVED &&
          campStatus == DeviceStatusCampStatus.ACTIVE) {
        return DeviceTrustRecovery.retained;
      }

      if (registrationStatus == DeviceStatusStatus.REVOKED) {
        await clearRegistration();
        return DeviceTrustRecovery.cleared;
      }

      // 보호된 트랙 API를 호출할 수 없는 상태(PENDING/REJECTED 등)는 더 이상
      // 등록된 기기로 취급하지 않는다. 응답이 불완전한 경우만 위에서 보존한다.
      await clearRegistration();
      return DeviceTrustRecovery.cleared;
    } on DioException catch (error, stackTrace) {
      debugPrint(
        '[device_trust] unauthorized recovery failed: '
        'type=${error.type} statusCode=${error.response?.statusCode}\n$stackTrace',
      );
      return DeviceTrustRecovery.unresolved;
    }
  }

  /// POST /device-registrations. 성공 시 PENDING 상태의 기기 신뢰 토큰을 저장하고
  /// APPROVED 전이 감지를 위한 폴링을 시작한다.
  Future<void> requestRegistration(
    String registrationCode, {
    required String displayName,
  }) async {
    final api = ref.read(authDeviceTrustApiProvider);
    final store = ref.read(secureTokenStoreProvider);
    final deviceModel = await _resolveDeviceModel();

    final response = await api.deviceRegistrationsPost(
      request: DeviceRegistrationsPostRequest(
        (DeviceRegistrationsPostRequestBuilder b) => b
          ..registrationCode = registrationCode
          ..deviceName = _defaultDeviceName()
          ..deviceModel = deviceModel
          ..displayName = displayName,
      ),
    );

    final registration = response.data;
    if (registration == null ||
        registration.id == null ||
        registration.status == null ||
        registration.deviceToken == null) {
      throw Exception('기기 등록 응답이 올바르지 않습니다.');
    }

    await store.write(_deviceRegistrationIdKey, registration.id!);
    await store.write(_deviceTrustTokenKey, registration.deviceToken!);
    final status = _fromApiStatus(registration.status!);
    await store.write(_deviceStatusKey, status.name);
    state = AsyncData(status);
    if (status == DeviceTrustStatus.pending) {
      _schedulePolling();
    }
  }

  /// 이 기기의 로컬 등록 정보를 폐기하고 새 캠프 등록 흐름으로 되돌린다.
  ///
  /// 서버의 기기 신뢰 철회 권한은 관리자/캠프 종료에 남겨 둔다. 이 메서드는
  /// 신뢰 철회가 이미 확인된 경우와 사용자의 수동 초기화 모두에서 로컬 저장소와
  /// provider 상태를 같은 방식으로 정리하는 단일 경로다.
  Future<void> clearRegistration() async {
    _pollTimer?.cancel();
    final store = ref.read(secureTokenStoreProvider);
    await Future.wait([
      store.delete(_deviceRegistrationIdKey),
      store.delete(_deviceStatusKey),
      store.delete(_deviceTrustTokenKey),
    ]);
    if (!ref.mounted) return;
    _pollTimer?.cancel();
    ref.invalidate(deviceTrustTokenProvider);
    state = const AsyncData(DeviceTrustStatus.none);
  }

  static String _defaultDeviceName() =>
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

  /// iOS는 사용자가 기기 설정에서 지정한 이름(예: "민수의 iPad")을, Android는 이런
  /// 사용자 지정 이름을 OS 차원에서 노출하지 않으므로 마케팅 모델명(예: "Pixel 7")을
  /// 반환한다. 참고용 필드라 실패해도 등록 요청 자체는 막지 않는다.
  static Future<String> _resolveDeviceModel() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.name;
      }
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return info.model;
      }
      return _defaultDeviceName();
    } catch (_) {
      return _defaultDeviceName();
    }
  }
}

/// 신뢰기기 등록 시 발급받아 저장해둔 토큰 — B1 PIN 로그인(`X-Device-Token` 헤더)에만 쓰인다.
@riverpod
Future<String?> deviceTrustToken(Ref ref) async {
  final store = ref.watch(secureTokenStoreProvider);
  return store.read(_deviceTrustTokenKey);
}
