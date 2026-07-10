# cornermon_api_gen.api.BCampCornerTrackApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**badgesBulkGeneratePost**](BCampCornerTrackApi.md#badgesbulkgeneratepost) | **POST** /badges/bulk-generate | QR 배지 사전 생성
[**badgesExportGet**](BCampCornerTrackApi.md#badgesexportget) | **GET** /badges/export | 미배정 배지 PDF 내보내기 (스티커 인쇄용)
[**badgesGet**](BCampCornerTrackApi.md#badgesget) | **GET** /badges | 배지 목록 조회
[**badgesIdRegisterPost**](BCampCornerTrackApi.md#badgesidregisterpost) | **POST** /badges/{id}/register | 배지 조 등록 (목록에서 선택)
[**badgesScanRegisterPost**](BCampCornerTrackApi.md#badgesscanregisterpost) | **POST** /badges/scan-register | 배지 조 등록 (카메라 QR 스캔)
[**campsGet**](BCampCornerTrackApi.md#campsget) | **GET** /camps | 캠프 목록 조회
[**campsIdEndPost**](BCampCornerTrackApi.md#campsidendpost) | **POST** /camps/{id}/end | 캠프 종료 (ACTIVE → ENDED)
[**campsIdGet**](BCampCornerTrackApi.md#campsidget) | **GET** /camps/{id} | 캠프 상세 조회
[**campsIdPatch**](BCampCornerTrackApi.md#campsidpatch) | **PATCH** /camps/{id} | 캠프 수정 (이름/기간/병목 파라미터)
[**campsIdStartPost**](BCampCornerTrackApi.md#campsidstartpost) | **POST** /camps/{id}/start | 캠프 시작 (PENDING → ACTIVE)
[**campsPost**](BCampCornerTrackApi.md#campspost) | **POST** /camps | 캠프 생성
[**cornersBulkUpdatePatch**](BCampCornerTrackApi.md#cornersbulkupdatepatch) | **PATCH** /corners/bulk-update | 코너 일괄 규칙 변경
[**cornersCornerIdTracksPost**](BCampCornerTrackApi.md#cornerscorneridtrackspost) | **POST** /corners/{cornerId}/tracks | 트랙 생성
[**cornersGet**](BCampCornerTrackApi.md#cornersget) | **GET** /corners | 코너 목록 조회
[**cornersIdPatch**](BCampCornerTrackApi.md#cornersidpatch) | **PATCH** /corners/{id} | 코너 규칙 변경 (단건)
[**cornersPost**](BCampCornerTrackApi.md#cornerspost) | **POST** /corners | 코너 일괄 생성
[**groupsGet**](BCampCornerTrackApi.md#groupsget) | **GET** /groups | 조 목록 조회
[**groupsIdGet**](BCampCornerTrackApi.md#groupsidget) | **GET** /groups/{id} | 조 상세 조회 (순회표 포함)
[**tracksBulkDeletePost**](BCampCornerTrackApi.md#tracksbulkdeletepost) | **POST** /tracks/bulk-delete | 트랙 일괄 삭제
[**tracksExportGet**](BCampCornerTrackApi.md#tracksexportget) | **GET** /tracks/export | 전체 트랙 PIN 목록 엑셀 다운로드
[**tracksGet**](BCampCornerTrackApi.md#tracksget) | **GET** /tracks | 전체 트랙 목록 조회
[**tracksIdDelete**](BCampCornerTrackApi.md#tracksiddelete) | **DELETE** /tracks/{id} | 트랙 삭제
[**tracksIdExportGet**](BCampCornerTrackApi.md#tracksidexportget) | **GET** /tracks/{id}/export | 트랙 단건 PIN 카드 내보내기
[**tracksIdRegeneratePinPost**](BCampCornerTrackApi.md#tracksidregeneratepinpost) | **POST** /tracks/{id}/regenerate-pin | 트랙 PIN 재발급
[**tracksIdReplacePost**](BCampCornerTrackApi.md#tracksidreplacepost) | **POST** /tracks/{id}/replace | 트랙 교체 (코너 담당 변경)


# **badgesBulkGeneratePost**
> BadgesBulkGeneratePost201Response badgesBulkGeneratePost(badgesBulkGeneratePostRequest)

QR 배지 사전 생성

캠프 선택과 무관하게 언제든 호출 가능. 미배정(UNASSIGNED) 배지를 대량 미리 생성해 인쇄 시간을 줄인다. 각 배지는 고유 QR payload와 짧은 ID를 발급받는다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final BadgesBulkGeneratePostRequest badgesBulkGeneratePostRequest = ; // BadgesBulkGeneratePostRequest | 

try {
    final response = api.badgesBulkGeneratePost(badgesBulkGeneratePostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->badgesBulkGeneratePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **badgesBulkGeneratePostRequest** | [**BadgesBulkGeneratePostRequest**](BadgesBulkGeneratePostRequest.md)|  | 

### Return type

[**BadgesBulkGeneratePost201Response**](BadgesBulkGeneratePost201Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesExportGet**
> Uint8List badgesExportGet()

미배정 배지 PDF 내보내기 (스티커 인쇄용)

미배정(UNASSIGNED) 배지 전체를 스티커 인쇄용 PDF로 내보낸다. iPad에서 AirPrint 없이 PDF만 내보내며, 인쇄는 별도 컴퓨터에서 수행. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();

try {
    final response = api.badgesExportGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->badgesExportGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/pdf

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesGet**
> BadgesGet200Response badgesGet(status, search)

배지 목록 조회

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final BadgeStatus status = ; // BadgeStatus | 상태 필터
final String search = search_example; // String | 짧은 ID 부분 일치 검색

try {
    final response = api.badgesGet(status, search);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->badgesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**BadgeStatus**](.md)| 상태 필터 | [optional] 
 **search** | **String**| 짧은 ID 부분 일치 검색 | [optional] 

### Return type

[**BadgesGet200Response**](BadgesGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesIdRegisterPost**
> Group badgesIdRegisterPost(id, badgesIdRegisterPostRequest)

배지 조 등록 (목록에서 선택)

목록에서 선택한 미배정 배지를 특정 조 이름과 묶어 조(Group) 엔티티를 생성한다. 배지 상태가 ASSIGNED로 변경된다. 이번 캠프에서 이미 ASSIGNED인 배지를 다시 등록하려 하면 거부. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 배지 ID
final BadgesIdRegisterPostRequest badgesIdRegisterPostRequest = ; // BadgesIdRegisterPostRequest | 

try {
    final response = api.badgesIdRegisterPost(id, badgesIdRegisterPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->badgesIdRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 배지 ID | 
 **badgesIdRegisterPostRequest** | [**BadgesIdRegisterPostRequest**](BadgesIdRegisterPostRequest.md)|  | 

### Return type

[**Group**](Group.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **badgesScanRegisterPost**
> Group badgesScanRegisterPost(badgesScanRegisterPostRequest)

배지 조 등록 (카메라 QR 스캔)

카메라로 스캔한 배지 QR payload로 조에 등록한다. `/badges/{id}/register`와 결과는 동일하고 입력 방식만 다르다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final BadgesScanRegisterPostRequest badgesScanRegisterPostRequest = ; // BadgesScanRegisterPostRequest | 

try {
    final response = api.badgesScanRegisterPost(badgesScanRegisterPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->badgesScanRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **badgesScanRegisterPostRequest** | [**BadgesScanRegisterPostRequest**](BadgesScanRegisterPostRequest.md)|  | 

### Return type

[**Group**](Group.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsGet**
> CampsGet200Response campsGet(status)

캠프 목록 조회

PENDING/ACTIVE/ENDED 상태 모두 포함하여 캠프 목록을 조회한다. PENDING 캠프도 목록에 표시되어 설정 작업을 재개할 수 있다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final CampStatus status = ; // CampStatus | 상태 필터 (없으면 전체 조회)

try {
    final response = api.campsGet(status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->campsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**CampStatus**](.md)| 상태 필터 (없으면 전체 조회) | [optional] 

### Return type

[**CampsGet200Response**](CampsGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdEndPost**
> Camp campsIdEndPost(id)

캠프 종료 (ACTIVE → ENDED)

프로그램(코너학습) 종료를 선언한다. 부분 완주 조는 그대로 기록되고 캠프 상태가 ENDED로 전이된다. 성공 시 캠프 결과 리포트 배치 생성이 자동으로 트리거된다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 캠프 ID

try {
    final response = api.campsIdEndPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->campsIdEndPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 

### Return type

[**Camp**](Camp.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdGet**
> Camp campsIdGet(id)

캠프 상세 조회

캠프 상세 정보를 조회한다. 캠프 목록에서 캠프를 선택하면 이후 코너/트랙/조/리포트 등 하위 엔티티 API는 세션에 저장된 \"현재 선택된 캠프\"를 암묵적으로 사용한다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 캠프 ID

try {
    final response = api.campsIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->campsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 

### Return type

[**Camp**](Camp.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdPatch**
> Camp campsIdPatch(id, campsIdPatchRequest)

캠프 수정 (이름/기간/병목 파라미터)

현재 선택된 캠프의 이름·기간 및 병목 판정 파라미터를 수정한다. ENDED 캠프는 수정 불가. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 캠프 ID
final CampsIdPatchRequest campsIdPatchRequest = ; // CampsIdPatchRequest | 

try {
    final response = api.campsIdPatch(id, campsIdPatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->campsIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 
 **campsIdPatchRequest** | [**CampsIdPatchRequest**](CampsIdPatchRequest.md)|  | [optional] 

### Return type

[**Camp**](Camp.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsIdStartPost**
> Camp campsIdStartPost(id)

캠프 시작 (PENDING → ACTIVE)

캠프 상태를 PENDING에서 ACTIVE로 전이한다. 이 호출이 성공해야만 해당 캠프 트랙의 PIN 로그인이 허용된다. 코너가 0개여도 시작 자체는 허용된다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 캠프 ID

try {
    final response = api.campsIdStartPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->campsIdStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 캠프 ID | 

### Return type

[**Camp**](Camp.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsPost**
> Camp campsPost(campsPostRequest)

캠프 생성

새 캠프를 생성한다. 생성된 캠프는 항상 PENDING 상태로 시작한다. 코너·트랙이 갖춰져도 자동으로 ACTIVE가 되지 않으며, 관리자가 명시적으로 시작해야 한다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final CampsPostRequest campsPostRequest = ; // CampsPostRequest | 

try {
    final response = api.campsPost(campsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->campsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campsPostRequest** | [**CampsPostRequest**](CampsPostRequest.md)|  | 

### Return type

[**Camp**](Camp.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersBulkUpdatePatch**
> CornersBulkUpdatePatch200Response cornersBulkUpdatePatch(cornersBulkUpdatePatchRequest)

코너 일괄 규칙 변경

선택된 코너들의 목표시간을 일괄 변경한다. 트랙 일괄 관리(A2B) 화면의 \"목표시간 일괄 변경\"에서 사용. 하나라도 실패하면 전체 롤백. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final CornersBulkUpdatePatchRequest cornersBulkUpdatePatchRequest = ; // CornersBulkUpdatePatchRequest | 

try {
    final response = api.cornersBulkUpdatePatch(cornersBulkUpdatePatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->cornersBulkUpdatePatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cornersBulkUpdatePatchRequest** | [**CornersBulkUpdatePatchRequest**](CornersBulkUpdatePatchRequest.md)|  | 

### Return type

[**CornersBulkUpdatePatch200Response**](CornersBulkUpdatePatch200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersCornerIdTracksPost**
> TracksGet200Response cornersCornerIdTracksPost(cornerId, cornersCornerIdTracksPostRequest)

트랙 생성

특정 코너에 트랙을 생성한다. `count`를 지정해 한 번에 여러 개 생성 가능. PIN은 자동 발급되며, 현재 ACTIVE 트랙과 겹치지 않는 유일한 값으로 부여된다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String cornerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 코너 ID
final CornersCornerIdTracksPostRequest cornersCornerIdTracksPostRequest = ; // CornersCornerIdTracksPostRequest | 

try {
    final response = api.cornersCornerIdTracksPost(cornerId, cornersCornerIdTracksPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->cornersCornerIdTracksPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cornerId** | **String**| 코너 ID | 
 **cornersCornerIdTracksPostRequest** | [**CornersCornerIdTracksPostRequest**](CornersCornerIdTracksPostRequest.md)|  | [optional] 

### Return type

[**TracksGet200Response**](TracksGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersGet**
> CornersGet200Response cornersGet()

코너 목록 조회

현재 선택된 캠프의 코너 목록과 각 코너의 운영 상태를 조회한다. - ADMIN: 전체 코너 목록 - TRACK: 자기 코너만 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();

try {
    final response = api.cornersGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->cornersGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CornersGet200Response**](CornersGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth), [TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersIdPatch**
> Corner cornersIdPatch(id, cornersIdPatchRequest)

코너 규칙 변경 (단건)

코너의 목표시간 등 규칙을 변경한다 (Rule Override). 동시 변경 시 Last-Write-Wins 정책 적용. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 코너 ID
final CornersIdPatchRequest cornersIdPatchRequest = ; // CornersIdPatchRequest | 

try {
    final response = api.cornersIdPatch(id, cornersIdPatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->cornersIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 코너 ID | 
 **cornersIdPatchRequest** | [**CornersIdPatchRequest**](CornersIdPatchRequest.md)|  | [optional] 

### Return type

[**Corner**](Corner.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cornersPost**
> CornersGet200Response cornersPost(cornersPostRequest)

코너 일괄 생성

코너 배열을 한 번에 생성한다. 초기 설정 마법사 2단계에서 사용. `initialTrackCount`만큼 트랙도 함께 생성되고 각 트랙에 PIN이 자동 발급된다. 하나라도 실패하면 전체가 롤백된다 (원자적 트랜잭션). 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final CornersPostRequest cornersPostRequest = ; // CornersPostRequest | 

try {
    final response = api.cornersPost(cornersPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->cornersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cornersPostRequest** | [**CornersPostRequest**](CornersPostRequest.md)|  | 

### Return type

[**CornersGet200Response**](CornersGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **groupsGet**
> GroupsGet200Response groupsGet(filter, sort, order)

조 목록 조회

현재 선택된 캠프의 조 목록을 조회한다. - ADMIN: 전체 조 목록 (수동 처리 UI에서 조 선택용 포함) - TRACK: 전체 조 목록 (방문 시작 시 조 선택용)  조는 배지 등록 API(`POST /badges/{id}/register` 또는 `POST /badges/scan-register`)를 통해서만 생성된다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String filter = filter_example; // String | 완주 여부 필터
final String sort = sort_example; // String | 
final String order = order_example; // String | 

try {
    final response = api.groupsGet(filter, sort, order);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->groupsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **filter** | **String**| 완주 여부 필터 | [optional] 
 **sort** | **String**|  | [optional] 
 **order** | **String**|  | [optional] 

### Return type

[**GroupsGet200Response**](GroupsGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth), [TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **groupsIdGet**
> Group groupsIdGet(id)

조 상세 조회 (순회표 포함)

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 조 ID

try {
    final response = api.groupsIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->groupsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 조 ID | 

### Return type

[**Group**](Group.md)

### Authorization

[AdminAuth](../README.md#AdminAuth), [TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksBulkDeletePost**
> tracksBulkDeletePost(tracksBulkDeletePostRequest)

트랙 일괄 삭제

선택한 트랙 목록을 일괄 삭제한다. 목록 중 IN_PROGRESS 방문이 있는 트랙이 하나라도 있으면 **전체를 거부** (부분 삭제 없음). 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final TracksBulkDeletePostRequest tracksBulkDeletePostRequest = ; // TracksBulkDeletePostRequest | 

try {
    api.tracksBulkDeletePost(tracksBulkDeletePostRequest);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksBulkDeletePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tracksBulkDeletePostRequest** | [**TracksBulkDeletePostRequest**](TracksBulkDeletePostRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksExportGet**
> Uint8List tracksExportGet()

전체 트랙 PIN 목록 엑셀 다운로드

현재 ACTIVE 트랙 전체의 PIN 목록을 xlsx 파일로 다운로드한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();

try {
    final response = api.tracksExportGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksExportGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksGet**
> TracksGet200Response tracksGet(sort, order)

전체 트랙 목록 조회

현재 선택된 캠프의 전체 트랙 목록 (ACTIVE/DELETED 포함 필터 가능). 코너별 그룹핑 형태로 반환. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String sort = sort_example; // String | 정렬 기준
final String order = order_example; // String | 정렬 방향

try {
    final response = api.tracksGet(sort, order);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sort** | **String**| 정렬 기준 | [optional] 
 **order** | **String**| 정렬 방향 | [optional] 

### Return type

[**TracksGet200Response**](TracksGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdDelete**
> tracksIdDelete(id, confirm)

트랙 삭제

트랙을 삭제한다. PIN 무효화 및 해당 트랙 세션 즉시 종료. - **하드 블록**: IN_PROGRESS 방문이 있는 트랙은 삭제 불가. - **소프트 게이트**: 코너의 마지막 트랙인 경우 `?confirm=true` 필요. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 트랙 ID
final bool confirm = true; // bool | 마지막 트랙 삭제 시 명시적 확인 플래그

try {
    api.tracksIdDelete(id, confirm);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 
 **confirm** | **bool**| 마지막 트랙 삭제 시 명시적 확인 플래그 | [optional] 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdExportGet**
> Uint8List tracksIdExportGet(id)

트랙 단건 PIN 카드 내보내기

특정 트랙 하나의 PIN 카드를 내보낸다. PIN 오염/분실이 의심되는 트랙만 재인쇄할 때 사용.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 트랙 ID

try {
    final response = api.tracksIdExportGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksIdExportGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/pdf

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdRegeneratePinPost**
> Track tracksIdRegeneratePinPost(id)

트랙 PIN 재발급

트랙 ID·코너·트랙 번호는 그대로 유지하고 PIN 값만 재발급한다. 기존 로그인된 진행자 세션도 즉시 강제 종료된다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 트랙 ID

try {
    final response = api.tracksIdRegeneratePinPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksIdRegeneratePinPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 

### Return type

[**Track**](Track.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksIdReplacePost**
> Track tracksIdReplacePost(id, tracksIdReplacePostRequest)

트랙 교체 (코너 담당 변경)

기존 트랙 삭제와 신규 코너에 신규 트랙 생성을 원자적으로 수행한다. IN_PROGRESS 방문이 있으면 하드 블록. 교체 성공 시 SSE `track.replaced` 이벤트로 기기에 새 세션 정보 전달. (세부 재인증 흐름 TBD) 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getBCampCornerTrackApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 트랙 ID
final TracksIdReplacePostRequest tracksIdReplacePostRequest = ; // TracksIdReplacePostRequest | 

try {
    final response = api.tracksIdReplacePost(id, tracksIdReplacePostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BCampCornerTrackApi->tracksIdReplacePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 트랙 ID | 
 **tracksIdReplacePostRequest** | [**TracksIdReplacePostRequest**](TracksIdReplacePostRequest.md)|  | 

### Return type

[**Track**](Track.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

