# cornermon_api_gen.api.AAuthDeviceTrustApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminsIdDelete**](AAuthDeviceTrustApi.md#adminsiddelete) | **DELETE** /admins/{id} | 관리자 삭제
[**adminsIdPasswordPatch**](AAuthDeviceTrustApi.md#adminsidpasswordpatch) | **PATCH** /admins/{id}/password | 관리자 비밀번호 변경
[**adminsPost**](AAuthDeviceTrustApi.md#adminspost) | **POST** /admins | 관리자 생성
[**authAdminLoginPost**](AAuthDeviceTrustApi.md#authadminloginpost) | **POST** /auth/admin/login | 관리자 로그인
[**authAdminLogoutPost**](AAuthDeviceTrustApi.md#authadminlogoutpost) | **POST** /auth/admin/logout | 관리자 로그아웃
[**authAdminSessionsGet**](AAuthDeviceTrustApi.md#authadminsessionsget) | **GET** /auth/admin/sessions | 관리자 세션 목록 조회
[**authAdminSessionsIdRevokePost**](AAuthDeviceTrustApi.md#authadminsessionsidrevokepost) | **POST** /auth/admin/sessions/{id}/revoke | 관리자 세션 강제 종료
[**authTrackLockoutDeviceIdReleasePost**](AAuthDeviceTrustApi.md#authtracklockoutdeviceidreleasepost) | **POST** /auth/track/lockout/{deviceId}/release | 디바이스 락아웃 해제
[**authTrackLoginPost**](AAuthDeviceTrustApi.md#authtrackloginpost) | **POST** /auth/track/login | 진행자 트랙 PIN 로그인
[**authTrackLogoutPost**](AAuthDeviceTrustApi.md#authtracklogoutpost) | **POST** /auth/track/logout | 진행자 트랙 로그아웃
[**authTrackSessionsGet**](AAuthDeviceTrustApi.md#authtracksessionsget) | **GET** /auth/track/sessions | 활성 진행자 세션 목록 조회
[**authTrackTrackIdForceLogoutPost**](AAuthDeviceTrustApi.md#authtracktrackidforcelogoutpost) | **POST** /auth/track/{trackId}/force-logout | 트랙 강제 로그아웃
[**campsCampIdDeviceRegistrationsGet**](AAuthDeviceTrustApi.md#campscampiddeviceregistrationsget) | **GET** /camps/{campId}/device-registrations | 기기 등록 목록 조회
[**campsCampIdDeviceRegistrationsIdApprovePost**](AAuthDeviceTrustApi.md#campscampiddeviceregistrationsidapprovepost) | **POST** /camps/{campId}/device-registrations/{id}/approve | 기기 승인
[**campsCampIdDeviceRegistrationsIdRejectPost**](AAuthDeviceTrustApi.md#campscampiddeviceregistrationsidrejectpost) | **POST** /camps/{campId}/device-registrations/{id}/reject | 기기 거절
[**campsCampIdDeviceRegistrationsIdRevokePost**](AAuthDeviceTrustApi.md#campscampiddeviceregistrationsidrevokepost) | **POST** /camps/{campId}/device-registrations/{id}/revoke | 기기 신뢰 취소 (폐기/분실)
[**campsCampIdDeviceRegistrationsLockedGet**](AAuthDeviceTrustApi.md#campscampiddeviceregistrationslockedget) | **GET** /camps/{campId}/device-registrations/locked | 잠금 기기 목록 조회
[**deviceRegistrationsMeGet**](AAuthDeviceTrustApi.md#deviceregistrationsmeget) | **GET** /device-registrations/me | 내 기기 등록 상태 자체 조회
[**deviceRegistrationsPost**](AAuthDeviceTrustApi.md#deviceregistrationspost) | **POST** /device-registrations | 기기 등록 요청 (최초 앱 실행 시)


# **adminsIdDelete**
> adminsIdDelete(id)

관리자 삭제

SYSTEM_ADMIN만 호출할 수 있습니다. 자기 자신은 삭제할 수 없으므로 마지막 SYSTEM_ADMIN 삭제 요청은 성립하지 않습니다. 삭제 시 admin_sessions는 DB foreign key cascade로 함께 제거됩니다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String id = id_example; // String | 관리자 ID

try {
    api.adminsIdDelete(id);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->adminsIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 관리자 ID | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminsIdPasswordPatch**
> adminsIdPasswordPatch(id, request)

관리자 비밀번호 변경

대상 관리자 본인 또는 SYSTEM_ADMIN만 호출할 수 있습니다. 비밀번호 변경은 기존 세션을 즉시 무효화하지 않으며, 현재 access token은 기존 TTL까지 유효합니다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String id = id_example; // String | 관리자 ID
final ChangeAdminPasswordRequest request = ; // ChangeAdminPasswordRequest | 새 비밀번호

try {
    api.adminsIdPasswordPatch(id, request);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->adminsIdPasswordPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 관리자 ID | 
 **request** | [**ChangeAdminPasswordRequest**](ChangeAdminPasswordRequest.md)| 새 비밀번호 | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminsPost**
> AdminResponse adminsPost(request)

관리자 생성

SYSTEM_ADMIN만 호출할 수 있습니다. 생성할 역할은 CORNER_OPERATOR로 고정되며, SYSTEM_ADMIN은 다른 SYSTEM_ADMIN을 생성할 수 없습니다. 동일한 username은 생성할 수 없습니다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final CreateAdminRequest request = ; // CreateAdminRequest | 생성할 관리자

try {
    final response = api.adminsPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->adminsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**CreateAdminRequest**](CreateAdminRequest.md)| 생성할 관리자 | 

### Return type

[**AdminResponse**](AdminResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAdminLoginPost**
> AdminLoginResponse authAdminLoginPost(request)

관리자 로그인

관리자 ID/비밀번호로 로그인하여 액세스 토큰을 발급받는다. 토큰은 슬라이딩 세션으로 활동이 있으면 만료가 연장된다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final AdminLoginRequest request = ; // AdminLoginRequest | 로그인 정보

try {
    final response = api.authAdminLoginPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authAdminLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**AdminLoginRequest**](AdminLoginRequest.md)| 로그인 정보 | 

### Return type

[**AdminLoginResponse**](AdminLoginResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAdminLogoutPost**
> authAdminLogoutPost()

관리자 로그아웃

현재 활성화된 리프레시 토큰(세션)을 취소(Revoke)한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();

try {
    api.authAdminLogoutPost();
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authAdminLogoutPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAdminSessionsGet**
> BuiltList<AdminSessionResponse> authAdminSessionsGet()

관리자 세션 목록 조회

현재 로그인된 관리자 세션 목록을 반환한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();

try {
    final response = api.authAdminSessionsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authAdminSessionsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AdminSessionResponse&gt;**](AdminSessionResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAdminSessionsIdRevokePost**
> authAdminSessionsIdRevokePost(id)

관리자 세션 강제 종료

특정 관리자 세션을 강제 만료 처리한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String id = id_example; // String | 세션 ID

try {
    api.authAdminSessionsIdRevokePost(id);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authAdminSessionsIdRevokePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 세션 ID | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackLockoutDeviceIdReleasePost**
> authTrackLockoutDeviceIdReleasePost(deviceId)

디바이스 락아웃 해제

관리자가 PIN 다회 오류로 잠긴 기기를 해제한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String deviceId = deviceId_example; // String | 기기 ID

try {
    api.authTrackLockoutDeviceIdReleasePost(deviceId);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackLockoutDeviceIdReleasePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| 기기 ID | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackLoginPost**
> TrackLoginResponse authTrackLoginPost(xDeviceToken, request)

진행자 트랙 PIN 로그인

신뢰 기기에서 트랙 PIN 으로 로그인하여 트랙 세션 토큰을 발급받는다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrustedDeviceAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrustedDeviceAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrustedDeviceAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String xDeviceToken = xDeviceToken_example; // String | 기기 신뢰 토큰 (opaque token, 값을 그대로 전달)
final TrackLoginRequest request = ; // TrackLoginRequest | 6자리 숫자 트랙 PIN

try {
    final response = api.authTrackLoginPost(xDeviceToken, request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xDeviceToken** | **String**| 기기 신뢰 토큰 (opaque token, 값을 그대로 전달) | 
 **request** | [**TrackLoginRequest**](TrackLoginRequest.md)| 6자리 숫자 트랙 PIN | 

### Return type

[**TrackLoginResponse**](TrackLoginResponse.md)

### Authorization

[TrustedDeviceAuth](../README.md#TrustedDeviceAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackLogoutPost**
> authTrackLogoutPost()

진행자 트랙 로그아웃

트랙 진행자가 스스로 로그아웃한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();

try {
    api.authTrackLogoutPost();
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackLogoutPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackSessionsGet**
> BuiltList<FacilitatorSessionResponse> authTrackSessionsGet(campId)

활성 진행자 세션 목록 조회

캠프 내 취소되지 않은(active) 진행자 세션 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.authTrackSessionsGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackSessionsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**BuiltList&lt;FacilitatorSessionResponse&gt;**](FacilitatorSessionResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackTrackIdForceLogoutPost**
> authTrackTrackIdForceLogoutPost(trackId)

트랙 강제 로그아웃

관리자가 특정 트랙의 진행자 세션을 강제 종료시킨다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String trackId = trackId_example; // String | 트랙 ID

try {
    api.authTrackTrackIdForceLogoutPost(trackId);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackTrackIdForceLogoutPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdDeviceRegistrationsGet**
> BuiltList<DeviceRegistrationResponse> campsCampIdDeviceRegistrationsGet(campId, status)

기기 등록 목록 조회

관리자가 등록되었거나 대기 중인 기기 목록을 확인한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String campId = campId_example; // String | 캠프 ID
final String status = status_example; // String | 기기 등록 상태

try {
    final response = api.campsCampIdDeviceRegistrationsGet(campId, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->campsCampIdDeviceRegistrationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 
 **status** | **String**| 기기 등록 상태 | [optional] 

### Return type

[**BuiltList&lt;DeviceRegistrationResponse&gt;**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdDeviceRegistrationsIdApprovePost**
> DeviceRegistrationResponse campsCampIdDeviceRegistrationsIdApprovePost(campId, id)

기기 승인

PENDING 상태인 기기를 APPROVED로 승인한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String campId = campId_example; // String | 캠프 ID
final String id = id_example; // String | 기기 등록 ID

try {
    final response = api.campsCampIdDeviceRegistrationsIdApprovePost(campId, id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->campsCampIdDeviceRegistrationsIdApprovePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 
 **id** | **String**| 기기 등록 ID | 

### Return type

[**DeviceRegistrationResponse**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdDeviceRegistrationsIdRejectPost**
> DeviceRegistrationResponse campsCampIdDeviceRegistrationsIdRejectPost(campId, id)

기기 거절

PENDING 상태인 기기를 REJECTED로 거절한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String campId = campId_example; // String | 캠프 ID
final String id = id_example; // String | 기기 등록 ID

try {
    final response = api.campsCampIdDeviceRegistrationsIdRejectPost(campId, id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->campsCampIdDeviceRegistrationsIdRejectPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 
 **id** | **String**| 기기 등록 ID | 

### Return type

[**DeviceRegistrationResponse**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdDeviceRegistrationsIdRevokePost**
> DeviceRegistrationResponse campsCampIdDeviceRegistrationsIdRevokePost(campId, id)

기기 신뢰 취소 (폐기/분실)

APPROVED 기기의 권한을 REVOKED로 박탈한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String campId = campId_example; // String | 캠프 ID
final String id = id_example; // String | 기기 등록 ID

try {
    final response = api.campsCampIdDeviceRegistrationsIdRevokePost(campId, id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->campsCampIdDeviceRegistrationsIdRevokePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 
 **id** | **String**| 기기 등록 ID | 

### Return type

[**DeviceRegistrationResponse**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdDeviceRegistrationsLockedGet**
> BuiltList<DeviceRegistrationResponse> campsCampIdDeviceRegistrationsLockedGet(campId)

잠금 기기 목록 조회

캠프 내 PIN 연속 실패로 잠금된(APPROVED, LockedUntil이 미래) 기기 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdDeviceRegistrationsLockedGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->campsCampIdDeviceRegistrationsLockedGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**BuiltList&lt;DeviceRegistrationResponse&gt;**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsMeGet**
> DeviceStatusResponse deviceRegistrationsMeGet(xDeviceToken)

내 기기 등록 상태 자체 조회

기기 등록 시 발급받은 opaque device token을 X-Device-Token 헤더에 넣어, 해당 기기의 승인 상태와 식별자를 조회한다. PENDING 상태에서도 호출할 수 있다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String xDeviceToken = xDeviceToken_example; // String | 기기 등록 토큰 (opaque token, POST /device-registrations 응답의 deviceToken 값)

try {
    final response = api.deviceRegistrationsMeGet(xDeviceToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsMeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xDeviceToken** | **String**| 기기 등록 토큰 (opaque token, POST /device-registrations 응답의 deviceToken 값) | 

### Return type

[**DeviceStatusResponse**](DeviceStatusResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsPost**
> DeviceRegistrationCreatedResponse deviceRegistrationsPost(request)

기기 등록 요청 (최초 앱 실행 시)

기기가 서버에 등록을 요청한다. 이후 관리자의 승인 대기.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final DeviceRegistrationRequest request = ; // DeviceRegistrationRequest | 등록 정보

try {
    final response = api.deviceRegistrationsPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**DeviceRegistrationRequest**](DeviceRegistrationRequest.md)| 등록 정보 | 

### Return type

[**DeviceRegistrationCreatedResponse**](DeviceRegistrationCreatedResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

