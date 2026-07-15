# cornermon_api_gen.api.BResourceManagementAdminApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**badgesBulkGeneratePost**](BResourceManagementAdminApi.md#badgesbulkgeneratepost) | **POST** /badges/bulk-generate | 초기 배지 일괄 생성
[**badgesExportGet**](BResourceManagementAdminApi.md#badgesexportget) | **GET** /badges/export | QR 배지 인쇄용 목록 내보내기 (JSON)
[**badgesGet**](BResourceManagementAdminApi.md#badgesget) | **GET** /badges | 전체 배지 목록 조회
[**badgesIdRegisterPost**](BResourceManagementAdminApi.md#badgesidregisterpost) | **POST** /badges/{id}/register | 배지를 특정 조에 배정 (수동)
[**badgesScanRegisterPost**](BResourceManagementAdminApi.md#badgesscanregisterpost) | **POST** /badges/scan-register | 배지를 특정 조에 배정 (스캔 기반)
[**campsCampIdCornersGet**](BResourceManagementAdminApi.md#campscampidcornersget) | **GET** /camps/{campId}/corners | 코너 목록 조회
[**campsCampIdGroupsGet**](BResourceManagementAdminApi.md#campscampidgroupsget) | **GET** /camps/{campId}/groups | 전체 조 목록 조회
[**campsCampIdTracksGet**](BResourceManagementAdminApi.md#campscampidtracksget) | **GET** /camps/{campId}/tracks | 트랙 목록 조회
[**campsGet**](BResourceManagementAdminApi.md#campsget) | **GET** /camps | 캠프 목록 조회
[**campsIdEndPost**](BResourceManagementAdminApi.md#campsidendpost) | **POST** /camps/{id}/end | 캠프 종료
[**campsIdGet**](BResourceManagementAdminApi.md#campsidget) | **GET** /camps/{id} | 캠프 상세 조회
[**campsIdPatch**](BResourceManagementAdminApi.md#campsidpatch) | **PATCH** /camps/{id} | 캠프 정보 및 병목 기준 수정
[**campsIdStartPost**](BResourceManagementAdminApi.md#campsidstartpost) | **POST** /camps/{id}/start | 캠프 시작
[**campsPost**](BResourceManagementAdminApi.md#campspost) | **POST** /camps | 새 캠프 생성
[**cornersBulkUpdatePut**](BResourceManagementAdminApi.md#cornersbulkupdateput) | **PUT** /corners/bulk-update | 코너 대량 수정
[**cornersCornerIdTracksGet**](BResourceManagementAdminApi.md#cornerscorneridtracksget) | **GET** /corners/{cornerId}/tracks | 코너별 트랙 목록 조회
[**cornersIdDelete**](BResourceManagementAdminApi.md#cornersiddelete) | **DELETE** /corners/{id} | 코너 삭제
[**cornersIdGet**](BResourceManagementAdminApi.md#cornersidget) | **GET** /corners/{id} | 코너 상세 조회
[**cornersPost**](BResourceManagementAdminApi.md#cornerspost) | **POST** /corners | 새 코너 추가
[**groupsIdGet**](BResourceManagementAdminApi.md#groupsidget) | **GET** /groups/{id} | 특정 조 상세 조회
[**groupsIdVisitsGet**](BResourceManagementAdminApi.md#groupsidvisitsget) | **GET** /groups/{id}/visits | 조별 방문 기록 조회
[**tracksBulkDeleteDelete**](BResourceManagementAdminApi.md#tracksbulkdeletedelete) | **DELETE** /tracks/bulk-delete | 트랙 일괄 삭제
[**tracksExportGet**](BResourceManagementAdminApi.md#tracksexportget) | **GET** /tracks/export | 트랙 인증 정보 전체 내보내기
[**tracksIdExportGet**](BResourceManagementAdminApi.md#tracksidexportget) | **GET** /tracks/{id}/export | 단일 트랙 인증 정보 내보내기
[**tracksIdGet**](BResourceManagementAdminApi.md#tracksidget) | **GET** /tracks/{id} | 트랙 상세 조회
[**tracksIdRegeneratePinPost**](BResourceManagementAdminApi.md#tracksidregeneratepinpost) | **POST** /tracks/{id}/regenerate-pin | PIN 재발급
[**tracksIdReplacePut**](BResourceManagementAdminApi.md#tracksidreplaceput) | **PUT** /tracks/{id}/replace | 트랙 교체 (비상용)
[**tracksPost**](BResourceManagementAdminApi.md#trackspost) | **POST** /tracks | 트랙 일괄 생성


# **badgesBulkGeneratePost**
> BuiltList<BadgeResponse> badgesBulkGeneratePost(request)

초기 배지 일괄 생성

특정 개수만큼 QR 배지를 대량으로 일괄 발급한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final BulkGenerateBadgesRequest request = ; // BulkGenerateBadgesRequest | 생성할 개수

try {
    final response = api.badgesBulkGeneratePost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->badgesBulkGeneratePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**BulkGenerateBadgesRequest**](BulkGenerateBadgesRequest.md)| 생성할 개수 | 

### Return type

[**BuiltList&lt;BadgeResponse&gt;**](BadgeResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesExportGet**
> ExportBadgesResponse badgesExportGet()

QR 배지 인쇄용 목록 내보내기 (JSON)

클라이언트가 직접 PDF 인쇄 및 레이아웃 구성을 할 수 있도록 미배정(UNASSIGNED) 배지 전체 목록을 JSON으로 다운로드한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();

try {
    final response = api.badgesExportGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->badgesExportGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ExportBadgesResponse**](ExportBadgesResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesGet**
> BuiltList<BadgeResponse> badgesGet()

전체 배지 목록 조회

시스템에 존재하는 전체 배지 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();

try {
    final response = api.badgesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->badgesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;BadgeResponse&gt;**](BadgeResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesIdRegisterPost**
> BadgeResponse badgesIdRegisterPost(id, request)

배지를 특정 조에 배정 (수동)

수동으로 특정 배지를 조회하여 조에 할당한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 배지 ID
final AssignBadgeRequest request = ; // AssignBadgeRequest | 배정할 조 ID

try {
    final response = api.badgesIdRegisterPost(id, request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->badgesIdRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 배지 ID | 
 **request** | [**AssignBadgeRequest**](AssignBadgeRequest.md)| 배정할 조 ID | 

### Return type

[**BadgeResponse**](BadgeResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesScanRegisterPost**
> GroupResponse badgesScanRegisterPost(request)

배지를 특정 조에 배정 (스캔 기반)

QR 코드를 스캔하여 배지를 특정 조에 등록(매핑)한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final ScanAssignBadgeRequest request = ; // ScanAssignBadgeRequest | 매핑 정보

try {
    final response = api.badgesScanRegisterPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->badgesScanRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**ScanAssignBadgeRequest**](ScanAssignBadgeRequest.md)| 매핑 정보 | 

### Return type

[**GroupResponse**](GroupResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdCornersGet**
> BuiltList<CornerResponse> campsCampIdCornersGet(campId)

코너 목록 조회

특정 캠프의 모든 코너 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdCornersGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsCampIdCornersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**BuiltList&lt;CornerResponse&gt;**](CornerResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdGroupsGet**
> BuiltList<GroupResponse> campsCampIdGroupsGet(campId)

전체 조 목록 조회

특정 캠프에 속한 모든 조의 목록과 상태를 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdGroupsGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsCampIdGroupsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**BuiltList&lt;GroupResponse&gt;**](GroupResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdTracksGet**
> BuiltList<TrackResponse> campsCampIdTracksGet(campId)

트랙 목록 조회

전체 트랙 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdTracksGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsCampIdTracksGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**BuiltList&lt;TrackResponse&gt;**](TrackResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsGet**
> BuiltList<CampResponse> campsGet()

캠프 목록 조회

전체 캠프 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();

try {
    final response = api.campsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;CampResponse&gt;**](CampResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdEndPost**
> CampResponse campsIdEndPost(id)

캠프 종료

캠프를 ENDED 상태로 변경한다. 이후 데이터 수정이 불가하다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 캠프 ID

try {
    final response = api.campsIdEndPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsIdEndPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 

### Return type

[**CampResponse**](CampResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdGet**
> CampResponse campsIdGet(id)

캠프 상세 조회

특정 캠프 정보를 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 캠프 ID

try {
    final response = api.campsIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 

### Return type

[**CampResponse**](CampResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdPatch**
> CampResponse campsIdPatch(id, request)

캠프 정보 및 병목 기준 수정

캠프 이름, 예정 기간, 병목 판정 기준 중 요청에 포함된 필드만 수정한다. 종료된 캠프는 수정할 수 없다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 캠프 ID
final UpdateCampRequest request = ; // UpdateCampRequest | 부분 수정할 캠프 설정

try {
    final response = api.campsIdPatch(id, request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 
 **request** | [**UpdateCampRequest**](UpdateCampRequest.md)| 부분 수정할 캠프 설정 | 

### Return type

[**CampResponse**](CampResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdStartPost**
> CampResponse campsIdStartPost(id)

캠프 시작

캠프를 ACTIVE 상태로 변경하고 운영을 시작한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 캠프 ID

try {
    final response = api.campsIdStartPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsIdStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 

### Return type

[**CampResponse**](CampResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsPost**
> CampResponse campsPost(request)

새 캠프 생성

새로운 코너학습 캠프를 생성한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final CreateCampRequest request = ; // CreateCampRequest | 캠프 생성 정보

try {
    final response = api.campsPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->campsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**CreateCampRequest**](CreateCampRequest.md)| 캠프 생성 정보 | 

### Return type

[**CampResponse**](CampResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersBulkUpdatePut**
> BuiltList<CornerResponse> cornersBulkUpdatePut(request)

코너 대량 수정

여러 코너의 이름이나 목표 시간을 일괄 수정한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final BulkUpdateCornersRequest request = ; // BulkUpdateCornersRequest | 수정할 코너 목록

try {
    final response = api.cornersBulkUpdatePut(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->cornersBulkUpdatePut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**BulkUpdateCornersRequest**](BulkUpdateCornersRequest.md)| 수정할 코너 목록 | 

### Return type

[**BuiltList&lt;CornerResponse&gt;**](CornerResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersCornerIdTracksGet**
> BuiltList<TrackResponse> cornersCornerIdTracksGet(cornerId)

코너별 트랙 목록 조회

특정 코너에 속한 트랙 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String cornerId = cornerId_example; // String | 코너 ID

try {
    final response = api.cornersCornerIdTracksGet(cornerId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->cornersCornerIdTracksGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cornerId** | **String**| 코너 ID | 

### Return type

[**BuiltList&lt;TrackResponse&gt;**](TrackResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersIdDelete**
> cornersIdDelete(id)

코너 삭제

코너를 삭제한다. 단, 방문 기록이 있으면 삭제할 수 없다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 코너 ID

try {
    api.cornersIdDelete(id);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->cornersIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 코너 ID | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersIdGet**
> CornerResponse cornersIdGet(id)

코너 상세 조회

특정 코너 정보를 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 코너 ID

try {
    final response = api.cornersIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->cornersIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 코너 ID | 

### Return type

[**CornerResponse**](CornerResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersPost**
> CornerResponse cornersPost(request)

새 코너 추가

캠프에 새로운 코너를 생성한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final CreateCornerRequest request = ; // CreateCornerRequest | 코너 생성 정보

try {
    final response = api.cornersPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->cornersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**CreateCornerRequest**](CreateCornerRequest.md)| 코너 생성 정보 | 

### Return type

[**CornerResponse**](CornerResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **groupsIdGet**
> GroupResponse groupsIdGet(id)

특정 조 상세 조회

특정 조의 현재 위치 및 순회표(Itinerary) 진행 상태를 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 조 ID

try {
    final response = api.groupsIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->groupsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 조 ID | 

### Return type

[**GroupResponse**](GroupResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **groupsIdVisitsGet**
> BuiltList<VisitSummaryResponse> groupsIdVisitsGet(id)

조별 방문 기록 조회

특정 조의 전체 방문(Visit) 기록과 각 코너의 소요 시간 등을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 조 ID

try {
    final response = api.groupsIdVisitsGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->groupsIdVisitsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 조 ID | 

### Return type

[**BuiltList&lt;VisitSummaryResponse&gt;**](VisitSummaryResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksBulkDeleteDelete**
> tracksBulkDeleteDelete(request)

트랙 일괄 삭제

선택한 트랙들을 일괄 삭제한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final BulkDeleteTracksRequest request = ; // BulkDeleteTracksRequest | 삭제할 트랙 ID 목록

try {
    api.tracksBulkDeleteDelete(request);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->tracksBulkDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**BulkDeleteTracksRequest**](BulkDeleteTracksRequest.md)| 삭제할 트랙 ID 목록 | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksExportGet**
> ExportTracksResponse tracksExportGet(campId)

트랙 인증 정보 전체 내보내기

인쇄를 위해 지정 캠프의 ACTIVE 트랙 PIN을 JSON으로 내려준다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.tracksExportGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->tracksExportGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**ExportTracksResponse**](ExportTracksResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdExportGet**
> TrackPinResponse tracksIdExportGet(id)

단일 트랙 인증 정보 내보내기

특정 트랙의 PIN을 JSON으로 내려준다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 트랙 ID

try {
    final response = api.tracksIdExportGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->tracksIdExportGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 

### Return type

[**TrackPinResponse**](TrackPinResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdGet**
> TrackResponse tracksIdGet(id)

트랙 상세 조회

트랙 상세 정보(PIN 등)를 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 트랙 ID

try {
    final response = api.tracksIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->tracksIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 

### Return type

[**TrackResponse**](TrackResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdRegeneratePinPost**
> TrackPinResponse tracksIdRegeneratePinPost(id)

PIN 재발급

특정 트랙의 PIN 번호를 새로 생성한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 트랙 ID

try {
    final response = api.tracksIdRegeneratePinPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->tracksIdRegeneratePinPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 

### Return type

[**TrackPinResponse**](TrackPinResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdReplacePut**
> TrackPinResponse tracksIdReplacePut(id, request)

트랙 교체 (비상용)

기존 트랙을 삭제하고 지정한 대상 코너에 새 트랙을 생성하며 기존 진행자 세션의 마이그레이션 대상을 설정한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final String id = id_example; // String | 트랙 ID
final ReplaceTrackRequest request = ; // ReplaceTrackRequest | 대상 코너

try {
    final response = api.tracksIdReplacePut(id, request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->tracksIdReplacePut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 
 **request** | [**ReplaceTrackRequest**](ReplaceTrackRequest.md)| 대상 코너 | 

### Return type

[**TrackPinResponse**](TrackPinResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksPost**
> BuiltList<TrackPinResponse> tracksPost(request)

트랙 일괄 생성

특정 코너에 여러 트랙을 추가 생성한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getBResourceManagementAdminApi();
final CreateTracksRequest request = ; // CreateTracksRequest | 생성 정보

try {
    final response = api.tracksPost(request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BResourceManagementAdminApi->tracksPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**CreateTracksRequest**](CreateTracksRequest.md)| 생성 정보 | 

### Return type

[**BuiltList&lt;TrackPinResponse&gt;**](TrackPinResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

