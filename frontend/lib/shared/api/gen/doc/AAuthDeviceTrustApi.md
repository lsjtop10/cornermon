# cornermon_api_gen.api.AAuthDeviceTrustApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authAdminLoginPost**](AAuthDeviceTrustApi.md#authadminloginpost) | **POST** /auth/admin/login | 관리자 로그인
[**authAdminRefreshPost**](AAuthDeviceTrustApi.md#authadminrefreshpost) | **POST** /auth/admin/refresh | 관리자 액세스 토큰 재발급 (Silent Refresh)
[**authAdminSessionsGet**](AAuthDeviceTrustApi.md#authadminsessionsget) | **GET** /auth/admin/sessions | 관리자 활성 세션 목록 조회
[**authAdminSessionsIdRevokePost**](AAuthDeviceTrustApi.md#authadminsessionsidrevokepost) | **POST** /auth/admin/sessions/{id}/revoke | 관리자 특정 세션 강제 종료
[**authTrackLockoutDeviceIdReleasePost**](AAuthDeviceTrustApi.md#authtracklockoutdeviceidreleasepost) | **POST** /auth/track/lockout/{deviceId}/release | PIN 잠금(지연) 즉시 해제
[**authTrackLoginPost**](AAuthDeviceTrustApi.md#authtrackloginpost) | **POST** /auth/track/login | 진행자 트랙 PIN 로그인
[**authTrackLogoutPost**](AAuthDeviceTrustApi.md#authtracklogoutpost) | **POST** /auth/track/logout | 진행자 자발적 로그아웃
[**authTrackTrackIdForceLogoutPost**](AAuthDeviceTrustApi.md#authtracktrackidforcelogoutpost) | **POST** /auth/track/{trackId}/force-logout | 특정 트랙 세션 강제 로그아웃
[**deviceRegistrationsGet**](AAuthDeviceTrustApi.md#deviceregistrationsget) | **GET** /device-registrations | 기기 등록 요청 목록 조회 (대기 목록)
[**deviceRegistrationsIdApprovePost**](AAuthDeviceTrustApi.md#deviceregistrationsidapprovepost) | **POST** /device-registrations/{id}/approve | 기기 등록 승인 (PENDING → APPROVED)
[**deviceRegistrationsIdRejectPost**](AAuthDeviceTrustApi.md#deviceregistrationsidrejectpost) | **POST** /device-registrations/{id}/reject | 기기 등록 거절 (PENDING → REJECTED)
[**deviceRegistrationsIdRevokePost**](AAuthDeviceTrustApi.md#deviceregistrationsidrevokepost) | **POST** /device-registrations/{id}/revoke | 승인된 기기 신뢰 회수 (APPROVED → REVOKED)
[**deviceRegistrationsPost**](AAuthDeviceTrustApi.md#deviceregistrationspost) | **POST** /device-registrations | 기기 등록 요청


# **authAdminLoginPost**
> AuthAdminLoginPost200Response authAdminLoginPost(authAdminLoginPostRequest)

관리자 로그인

관리자 ID/비밀번호로 로그인하여 액세스 토큰(수명 15~30분)과 리프레시 토큰(슬라이딩 만료 12시간)을 발급받는다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final AuthAdminLoginPostRequest authAdminLoginPostRequest = ; // AuthAdminLoginPostRequest | 

try {
    final response = api.authAdminLoginPost(authAdminLoginPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authAdminLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authAdminLoginPostRequest** | [**AuthAdminLoginPostRequest**](AuthAdminLoginPostRequest.md)|  | 

### Return type

[**AuthAdminLoginPost200Response**](AuthAdminLoginPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAdminRefreshPost**
> AuthAdminRefreshPost200Response authAdminRefreshPost()

관리자 액세스 토큰 재발급 (Silent Refresh)

리프레시 토큰으로 새 액세스 토큰을 발급한다. 리프레시 토큰의 슬라이딩 만료 시계도 리셋된다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

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

[**AuthAdminRefreshPost200Response**](AuthAdminRefreshPost200Response.md)

### Authorization

[AdminRefreshAuth](../README.md#AdminRefreshAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAdminSessionsGet**
> AuthAdminSessionsGet200Response authAdminSessionsGet()

관리자 활성 세션 목록 조회

관리자 2인 모두의 활성 리프레시 토큰(세션) 목록을 조회한다. 기기 분실 등 상황에서 상대방 세션을 강제 종료하기 위한 목적. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

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

[**AuthAdminSessionsGet200Response**](AuthAdminSessionsGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAdminSessionsIdRevokePost**
> authAdminSessionsIdRevokePost(id)

관리자 특정 세션 강제 종료

자신 또는 상대 관리자의 리프레시 토큰 세션을 강제 폐기한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 세션(리프레시 토큰) ID

try {
    api.authAdminSessionsIdRevokePost(id);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authAdminSessionsIdRevokePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 세션(리프레시 토큰) ID | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackLockoutDeviceIdReleasePost**
> authTrackLockoutDeviceIdReleasePost(deviceId)

PIN 잠금(지연) 즉시 해제

관리자가 특정 기기의 PIN 실패 카운트와 지연 상태를 즉시 초기화한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String deviceId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 기기 등록 ID

try {
    api.authTrackLockoutDeviceIdReleasePost(deviceId);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackLockoutDeviceIdReleasePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**| 기기 등록 ID | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackLoginPost**
> AuthTrackLoginPost200Response authTrackLoginPost(authTrackLoginPostRequest)

진행자 트랙 PIN 로그인

신뢰 기기에서 트랙 PIN 으로 로그인하여 트랙 세션 토큰을 발급받는다. - 신뢰 기기(APPROVED 토큰)가 아니면 즉시 거부 (하드 블록). - 해당 트랙이 속한 캠프가 ACTIVE 상태가 아니면 거부 — PENDING 단계에서 PIN은 미리 발급돼 인쇄 가능하지만 로그인은 불가. - 로그인 성공 응답에 코너·트랙 표시명을 포함해 클라이언트가 확인 모달(B1-b)에 즉시 표시할 수 있도록 한다. - 연속 실패 시 점증형 지연(§domain-model.md 3.4) 적용. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final AuthTrackLoginPostRequest authTrackLoginPostRequest = ; // AuthTrackLoginPostRequest | 

try {
    final response = api.authTrackLoginPost(authTrackLoginPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authTrackLoginPostRequest** | [**AuthTrackLoginPostRequest**](AuthTrackLoginPostRequest.md)|  | 

### Return type

[**AuthTrackLoginPost200Response**](AuthTrackLoginPost200Response.md)

### Authorization

[TrustedDeviceAuth](../README.md#TrustedDeviceAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackLogoutPost**
> authTrackLogoutPost()

진행자 자발적 로그아웃

코너·트랙 확인 모달(B1-b)에서 \"아니요, 다시 로그인\"을 눌렀을 때 방금 발급된 세션을 즉시 폐기한다. 관리자 강제 로그아웃과 달리 본인 세션을 스스로 종료하는 경로. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

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
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTrackTrackIdForceLogoutPost**
> authTrackTrackIdForceLogoutPost(trackId)

특정 트랙 세션 강제 로그아웃

관리자가 특정 트랙의 진행자 세션을 강제 종료한다. 진행 중인 방문이 있어도 즉시 실행된다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String trackId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.authTrackTrackIdForceLogoutPost(trackId);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->authTrackTrackIdForceLogoutPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsGet**
> DeviceRegistrationsGet200Response deviceRegistrationsGet(status)

기기 등록 요청 목록 조회 (대기 목록)

관리자가 승인 대기 중인 기기 등록 요청 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final DeviceRegistrationStatus status = ; // DeviceRegistrationStatus | 상태 필터 (기본값: PENDING)

try {
    final response = api.deviceRegistrationsGet(status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**DeviceRegistrationStatus**](.md)| 상태 필터 (기본값: PENDING) | [optional] 

### Return type

[**DeviceRegistrationsGet200Response**](DeviceRegistrationsGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsIdApprovePost**
> DeviceRegistration deviceRegistrationsIdApprovePost(id)

기기 등록 승인 (PENDING → APPROVED)

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 기기 등록 요청 ID

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
 **id** | **String**| 기기 등록 요청 ID | 

### Return type

[**DeviceRegistration**](DeviceRegistration.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsIdRejectPost**
> DeviceRegistration deviceRegistrationsIdRejectPost(id)

기기 등록 거절 (PENDING → REJECTED)

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

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
 **id** | **String**|  | 

### Return type

[**DeviceRegistration**](DeviceRegistration.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsIdRevokePost**
> DeviceRegistration deviceRegistrationsIdRevokePost(id)

승인된 기기 신뢰 회수 (APPROVED → REVOKED)

이미 승인된 기기의 신뢰를 즉시 철회한다. 해당 기기는 PIN 입력 화면에 더 이상 접근할 수 없다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

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
 **id** | **String**|  | 

### Return type

[**DeviceRegistration**](DeviceRegistration.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deviceRegistrationsPost**
> DeviceRegistrationsPost201Response deviceRegistrationsPost(deviceRegistrationsPostRequest)

기기 등록 요청

진행자 기기가 등록 코드와 함께 신뢰 기기 등록을 요청한다. 성공 시 PENDING 상태의 기기 신뢰 토큰을 즉시 발급해 응답에 담아준다. 이 토큰은 관리자가 승인(APPROVED)할 때까지 PIN 입력 화면 진입이 불가능하다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getAAuthDeviceTrustApi();
final DeviceRegistrationsPostRequest deviceRegistrationsPostRequest = ; // DeviceRegistrationsPostRequest | 

try {
    final response = api.deviceRegistrationsPost(deviceRegistrationsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AAuthDeviceTrustApi->deviceRegistrationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceRegistrationsPostRequest** | [**DeviceRegistrationsPostRequest**](DeviceRegistrationsPostRequest.md)|  | 

### Return type

[**DeviceRegistrationsPost201Response**](DeviceRegistrationsPost201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

