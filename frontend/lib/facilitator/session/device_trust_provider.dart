import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';

part 'device_trust_provider.g.dart';

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

@riverpod
class DeviceTrust extends _$DeviceTrust {
  @override
  Future<DeviceTrustStatus> build() async {
    final store = ref.watch(secureTokenStoreProvider);
    final statusName = await store.read(_deviceStatusKey);
    return DeviceTrustStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => DeviceTrustStatus.none,
    );
  }

  /// POST /device-registrations. 성공 시 PENDING 상태의 기기 신뢰 토큰을 저장한다.
  ///
  /// PENDING → APPROVED 전이 감지는 GET /device-registrations/me 폴링으로 가능함이
  /// 확인됨(#107). 폴링 자체(기본 15초 간격)는 #109 이번 착수분 스코프 밖 — 별도 plan
  /// 참고.
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
