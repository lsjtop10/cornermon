import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';
import 'no_retry.dart';
import '../not_implemented_exception.dart';

part 'auth_device_trust_providers.g.dart';

@riverpod
AAuthDeviceTrustApi authDeviceTrustApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return AAuthDeviceTrustApi(dio, standardSerializers);
}

@Riverpod(retry: noRetry)
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

@Riverpod(retry: noRetry)
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

@Riverpod(retry: noRetry)
Future<void> revokeAdminSession(Ref ref, String sessionId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  await apiInstance.authAdminSessionsIdRevokePost(id: sessionId);
}

@Riverpod(retry: noRetry)
Future<void> releaseTrackLockout(Ref ref, String deviceId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  await apiInstance.authTrackLockoutDeviceIdReleasePost(deviceId: deviceId);
}

@Riverpod(retry: noRetry)
Future<void> forceLogoutTrack(Ref ref, TrackId trackId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  await apiInstance.authTrackTrackIdForceLogoutPost(trackId: trackId.value);
}

@riverpod
Future<List<FacilitatorSession>> activeSessionList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  try {
    final response = await apiInstance.authTrackSessionsGet(campId: campId.value);
    return response.data?.toList() ?? [];
  } on DioException catch (e) {
    if (e.response?.statusCode == 501) {
      throw const NotImplementedException('active-sessions');
    }
    rethrow;
  }
}

@riverpod
Future<List<DeviceRegistration>> deviceRegistrationList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.campsCampIdDeviceRegistrationsGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@riverpod
Future<List<DeviceRegistration>> lockedDeviceList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  try {
    final response = await apiInstance.campsCampIdDeviceRegistrationsLockedGet(campId: campId.value);
    return response.data?.toList() ?? [];
  } on DioException catch (e) {
    if (e.response?.statusCode == 501) {
      throw const NotImplementedException('locked-devices');
    }
    rethrow;
  }
}

@Riverpod(retry: noRetry)
Future<DeviceRegistration> approveDeviceRegistration(Ref ref, CampId campId, DeviceRegistrationId id) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.campsCampIdDeviceRegistrationsIdApprovePost(campId: campId.value, id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Device registration approve response was empty');
  }
  return data;
}

@Riverpod(retry: noRetry)
Future<DeviceRegistration> rejectDeviceRegistration(Ref ref, CampId campId, DeviceRegistrationId id) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.campsCampIdDeviceRegistrationsIdRejectPost(campId: campId.value, id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Device registration reject response was empty');
  }
  return data;
}

@Riverpod(retry: noRetry)
Future<DeviceRegistration> revokeDeviceRegistration(Ref ref, CampId campId, DeviceRegistrationId id) async {
  final apiInstance = ref.watch(authDeviceTrustApiProvider);
  final response = await apiInstance.campsCampIdDeviceRegistrationsIdRevokePost(campId: campId.value, id: id.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Device registration revoke response was empty');
  }
  return data;
}
