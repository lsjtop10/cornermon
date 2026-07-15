# cornermon_api_gen.api.DReportApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**campsCampIdReportsCurrentExportGet**](DReportApi.md#campscampidreportscurrentexportget) | **GET** /camps/{campId}/reports/current/export | 현재 리포트 데이터 내보내기
[**campsCampIdReportsCurrentGet**](DReportApi.md#campscampidreportscurrentget) | **GET** /camps/{campId}/reports/current | 현재 리포트 전체 조회
[**campsCampIdReportsGeneratePost**](DReportApi.md#campscampidreportsgeneratepost) | **POST** /camps/{campId}/reports/generate | 과거 리포트 생성 및 저장
[**campsCampIdReportsLiveSummaryGet**](DReportApi.md#campscampidreportslivesummaryget) | **GET** /camps/{campId}/reports/live-summary | 라이브 서머리 (대시보드 상단)


# **campsCampIdReportsCurrentExportGet**
> CampReportResponse campsCampIdReportsCurrentExportGet(campId)

현재 리포트 데이터 내보내기

현재 캠프 리포트를 다운로드한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getDReportApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdReportsCurrentExportGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DReportApi->campsCampIdReportsCurrentExportGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**CampReportResponse**](CampReportResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdReportsCurrentGet**
> CampReportResponse campsCampIdReportsCurrentGet(campId)

현재 리포트 전체 조회

현재 활성화된 캠프의 상세 통계(CampReport)를 반환한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getDReportApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdReportsCurrentGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DReportApi->campsCampIdReportsCurrentGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**CampReportResponse**](CampReportResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdReportsGeneratePost**
> CampReportResponse campsCampIdReportsGeneratePost(campId)

과거 리포트 생성 및 저장

캠프가 종료될 때 최종 리포트를 생성하여 저장소에 보관한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getDReportApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdReportsGeneratePost(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DReportApi->campsCampIdReportsGeneratePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**CampReportResponse**](CampReportResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdReportsLiveSummaryGet**
> CampSummaryStatsResponse campsCampIdReportsLiveSummaryGet(campId)

라이브 서머리 (대시보드 상단)

전체 진행 상황(완주율 등)의 핵심 요약 정보를 반환한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getDReportApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdReportsLiveSummaryGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DReportApi->campsCampIdReportsLiveSummaryGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**CampSummaryStatsResponse**](CampSummaryStatsResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

