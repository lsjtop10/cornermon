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

      _pollTimer?.cancel();
      await store.write(_deviceStatusKey, newStatus.name);
      if (newStatus == DeviceTrustStatus.revoked) {
        // 회수된 기기 토큰은 즉시 폐기한다 — 재등록 시 requestRegistration이
        // 새 토큰으로 덮어쓰므로 남겨둘 이유가 없다. 트랙 세션 말소는
        // track_session_provider가 이 상태 전이를 직접 구독해 처리한다.
        await store.delete(_deviceTrustTokenKey);
      }
      state = AsyncData(newStatus);
    } on DioException catch (error, stackTrace) {
      // 일시적 네트워크 오류로 폴링 자체를 멈추지 않는다 — 다음 tick에 재시도.
      debugPrint(
        '[device_trust] polling failed: type=${error.type} '
        'statusCode=${error.response?.statusCode}\n$stackTrace',
      );
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
