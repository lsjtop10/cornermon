import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';

part 'auth_device_trust_providers.g.dart';

@riverpod
AAuthDeviceTrustApi authDeviceTrustApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return AAuthDeviceTrustApi(dio, standardSerializers);
}

@riverpod
Future<AdminLoginResponse> adminLogin(Ref ref, String id, String password) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.authAdminLoginPost(
    request: AdminLoginRequest(
      (b) => b
        ..id = id
        ..password = password,
    ),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Admin login response was empty');
  }
  return data;
}

@riverpod
Future<void> adminLogout(Ref ref) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  await apiInstance.authAdminLogoutPost();
}

@riverpod
Future<List<AdminSession>> adminSessionList(Ref ref) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.authAdminSessionsGet();
  return response.data?.toList() ?? [];
}

@riverpod
Future<void> revokeAdminSession(Ref ref, String sessionId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  await apiInstance.authAdminSessionsIdRevokePost(id: sessionId);
}

@riverpod
Future<void> releaseTrackLockout(Ref ref, String deviceId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  await apiInstance.authTrackLockoutDeviceIdReleasePost(deviceId: deviceId);
}

@riverpod
Future<void> forceLogoutTrack(Ref ref, TrackId trackId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  await apiInstance.authTrackTrackIdForceLogoutPost(trackId: trackId.value);
}

@riverpod
Future<List<FacilitatorSession>> activeSessionList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.authTrackSessionsGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@riverpod
Future<List<DeviceRegistration>> deviceRegistrationList(Ref ref) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.deviceRegistrationsGet();
  return response.data?.toList() ?? [];
}

@riverpod
Future<List<DeviceRegistration>> lockedDeviceList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.deviceRegistrationsLockedGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@riverpod
Future<DeviceRegistration> approveDeviceRegistration(Ref ref, DeviceRegistrationId id) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.deviceRegistrationsIdApprovePost(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Device registration approve response was empty');
  }
  return data;
}

@riverpod
Future<DeviceRegistration> rejectDeviceRegistration(Ref ref, DeviceRegistrationId id) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.deviceRegistrationsIdRejectPost(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Device registration reject response was empty');
  }
  return data;
}

@riverpod
Future<DeviceRegistration> revokeDeviceRegistration(Ref ref, DeviceRegistrationId id) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.deviceRegistrationsIdRevokePost(id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Device registration revoke response was empty');
  }
  return data;
}
