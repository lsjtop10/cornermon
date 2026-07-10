import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

import '../../shared/api/providers/auth_device_trust_providers.dart';
import '../../shared/auth/secure_token_store.dart';

part 'device_trust_provider.g.dart';

/// §2.4-b. `none`은 아직 등록 요청을 보낸 적 없는 클라이언트 로컬 상태이고,
/// 나머지 4개는 [DeviceRegistrationStatus](서버)를 그대로 미러링한다.
enum DeviceTrustStatus { none, pending, approved, rejected, revoked }

const _deviceTokenKey = 'device_trust_token';
const _deviceRegistrationIdKey = 'device_trust_registration_id';
const _deviceStatusKey = 'device_trust_status';

DeviceTrustStatus _fromApiStatus(DeviceRegistrationStatus status) => switch (status) {
      DeviceRegistrationStatus.PENDING => DeviceTrustStatus.pending,
      DeviceRegistrationStatus.APPROVED => DeviceTrustStatus.approved,
      DeviceRegistrationStatus.REJECTED => DeviceTrustStatus.rejected,
      DeviceRegistrationStatus.REVOKED => DeviceTrustStatus.revoked,
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
  /// TODO(도메인 미결정): 등록 이후 PENDING → APPROVED 전이를 이 클라이언트가 스스로
  /// 감지할 방법이 API 계약에 없다(전용 상태조회 GET 없음, /events/track/{trackId}는
  /// 트랙 세션 확보 후에만 구독 가능). 04_auth_and_realtime.md D-4 미해결 과제로 기록.
  /// 임시 방편: 승인 여부는 Phase 05의 B1 PIN 로그인 시도 응답으로만 간접 확인된다.
  Future<void> requestRegistration(String registrationCode) async {
    final api = ref.read(authDeviceTrustApiProvider);
    final store = ref.read(secureTokenStoreProvider);

    final response = await api.deviceRegistrationsPost(
      deviceRegistrationsPostRequest: DeviceRegistrationsPostRequest(
        (DeviceRegistrationsPostRequestBuilder b) => b
          ..registrationCode = registrationCode
          ..deviceName = _defaultDeviceName(),
      ),
    );

    final registration = response.data?.deviceRegistration;
    final deviceToken = response.data?.deviceToken;
    if (registration == null || deviceToken == null) {
      throw Exception('기기 등록 응답이 올바르지 않습니다.');
    }

    await store.write(_deviceTokenKey, deviceToken);
    await store.write(_deviceRegistrationIdKey, registration.id);
    final status = _fromApiStatus(registration.status);
    await store.write(_deviceStatusKey, status.name);
    state = AsyncData(status);
  }

  static String _defaultDeviceName() =>
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
}
