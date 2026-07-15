# cornermon_api_gen.api.AAuthDeviceTrustApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authAdminLoginPost**](AAuthDeviceTrustApi.md#authadminloginpost) | **POST** /auth/admin/login | 관리자 로그인
[**authAdminLogoutPost**](AAuthDeviceTrustApi.md#authadminlogoutpost) | **POST** /auth/admin/logout | 관리자 로그아웃
[**authAdminRefreshPost**](AAuthDeviceTrustApi.md#authadminrefreshpost) | **POST** /auth/admin/refresh | 관리자 액세스 토큰 재발급
[**authAdminSessionsGet**](AAuthDeviceTrustApi.md#authadminsessionsget) | **GET** /auth/admin/sessions | 관리자 세션 목록 조회
[**authAdminSessionsIdRevokePost**](AAuthDeviceTrustApi.md#authadminsessionsidrevokepost) | **POST** /auth/admin/sessions/{id}/revoke | 관리자 세션 강제 종료
[**authTrackLockoutDeviceIdReleasePost**](AAuthDeviceTrustApi.md#authtracklockoutdeviceidreleasepost) | **POST** /auth/track/lockout/{deviceId}/release | 디바이스 락아웃 해제
[**authTrackLoginPost**](AAuthDeviceTrustApi.md#authtrackloginpost) | **POST** /auth/track/login | 진행자 트랙 PIN 로그인
[**authTrackLogoutPost**](AAuthDeviceTrustApi.md#authtracklogoutpost) | **POST** /auth/track/logout | 진행자 트랙 로그아웃
[**authTrackSessionsGet**](AAuthDeviceTrustApi.md#authtracksessionsget) | **GET** /auth/track/sessions | 활성 진행자 세션 목록 조회
[**authTrackTrackIdForceLogoutPost**](AAuthDeviceTrustApi.md#authtracktrackidforcelogoutpost) | **POST** /auth/track/{trackId}/force-logout | 트랙 강제 로그아웃
[**deviceRegistrationsGet**](AAuthDeviceTrustApi.md#deviceregistrationsget) | **GET** /device-registrations | 기기 등록 목록 조회
[**deviceRegistrationsIdApprovePost**](AAuthDeviceTrustApi.md#deviceregistrationsidapprovepost) | **POST** /device-registrations/{id}/approve | 기기 승인
[**deviceRegistrationsIdRejectPost**](AAuthDeviceTrustApi.md#deviceregistrationsidrejectpost) | **POST** /device-registrations/{id}/reject | 기기 거절
[**deviceRegistrationsIdRevokePost**](AAuthDeviceTrustApi.md#deviceregistrationsidrevokepost) | **POST** /device-registrations/{id}/revoke | 기기 신뢰 취소 (폐기/분실)
[**deviceRegistrationsLockedGet**](AAuthDeviceTrustApi.md#deviceregistrationslockedget) | **GET** /device-registrations/locked | 잠금 기기 목록 조회
[**deviceRegistrationsMeGet**](AAuthDeviceTrustApi.md#deviceregistrationsmeget) | **GET** /device-registrations/me | 내 기기 등록 상태 자체 조회
[**deviceRegistrationsPost**](AAuthDeviceTrustApi.md#deviceregistrationspost) | **POST** /device-registrations | 기기 등록 요청 (최초 앱 실행 시)


# **authAdminLoginPost**
> AdminLoginResponse authAdminLoginPost(request)

관리자 로그인

관리자 ID/비밀번호로 로그인하여 액세스 토큰과 리프레시 토큰을 발급받는다.

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

# **authAdminRefreshPost**
> AdminRefreshResponse authAdminRefreshPost()

관리자 액세스 토큰 재발급

리프레시 토큰으로 새 액세스 토큰을 발급한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminRefreshAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminRefreshAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminRefreshAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getAAuthDeviceTrustApi();

try {
    final response = api.authAdminRefreshPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authAdminRefreshPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminRefreshResponse**](AdminRefreshResponse.md)

### Authorization

[AdminRefreshAuth](../README.md#AdminRefreshAuth)

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
> TrackLoginResponse authTrackLoginPost(request)

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
final TrackLoginRequest request = ; // TrackLoginRequest | 6자리 숫자 트랙 PIN

try {
    final response = api.authTrackLoginPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
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

# **deviceRegistrationsGet**
> BuiltList<DeviceRegistrationResponse> deviceRegistrationsGet()

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

try {
    final response = api.deviceRegistrationsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;DeviceRegistrationResponse&gt;**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsIdApprovePost**
> DeviceRegistrationResponse deviceRegistrationsIdApprovePost(id)

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
final String id = id_example; // String | 기기 등록 ID

try {
    final response = api.deviceRegistrationsIdApprovePost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsIdApprovePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 기기 등록 ID | 

### Return type

[**DeviceRegistrationResponse**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsIdRejectPost**
> DeviceRegistrationResponse deviceRegistrationsIdRejectPost(id)

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
final String id = id_example; // String | 기기 등록 ID

try {
    final response = api.deviceRegistrationsIdRejectPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsIdRejectPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 기기 등록 ID | 

### Return type

[**DeviceRegistrationResponse**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsIdRevokePost**
> DeviceRegistrationResponse deviceRegistrationsIdRevokePost(id)

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
final String id = id_example; // String | 기기 등록 ID

try {
    final response = api.deviceRegistrationsIdRevokePost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsIdRevokePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 기기 등록 ID | 

### Return type

[**DeviceRegistrationResponse**](DeviceRegistrationResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsLockedGet**
> BuiltList<DeviceRegistrationResponse> deviceRegistrationsLockedGet(campId)

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
    final response = api.deviceRegistrationsLockedGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsLockedGet: $e\n');
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
> BuiltMap<String, JsonObject> deviceRegistrationsMeGet()

내 기기 등록 상태 자체 조회

미승인(PENDING) 기기가 자신의 승인 상태를 확인하기 위해 호출한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();

try {
    final response = api.deviceRegistrationsMeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsMeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsPost**
> DeviceRegistrationResponse deviceRegistrationsPost(request)

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

[**DeviceRegistrationResponse**](DeviceRegistrationResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

