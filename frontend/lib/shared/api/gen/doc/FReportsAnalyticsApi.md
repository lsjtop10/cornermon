# cornermon_api_gen.api.FReportsAnalyticsApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**reportsCurrentExportGet**](FReportsAnalyticsApi.md#reportscurrentexportget) | **GET** /reports/current/export | 캠프 결과 리포트 PDF 내보내기
[**reportsCurrentGet**](FReportsAnalyticsApi.md#reportscurrentget) | **GET** /reports/current | 현재 캠프 결과 리포트 조회
[**reportsGeneratePost**](FReportsAnalyticsApi.md#reportsgeneratepost) | **POST** /reports/generate | 캠프 결과 리포트 배치 생성 (내부용)
[**reportsLiveSummaryGet**](FReportsAnalyticsApi.md#reportslivesummaryget) | **GET** /reports/live-summary | 실시간 스냅샷 요약


# **reportsCurrentExportGet**
> Uint8List reportsCurrentExportGet()

캠프 결과 리포트 PDF 내보내기

캠프 결과 리포트를 PDF로 다운로드한다. iPad에서 AirPrint 없이 PDF만 내보내며, 인쇄는 별도 컴퓨터에서 수행. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getFReportsAnalyticsApi();

try {
    final response = api.reportsCurrentExportGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling FReportsAnalyticsApi->reportsCurrentExportGet: $e\n');
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
 - **Accept**: application/pdf, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportsCurrentGet**
> CampReport reportsCurrentGet()

현재 캠프 결과 리포트 조회

현재 선택된 캠프의 전체 결과 리포트를 조회한다. - 캠프 진행 중: 일부 지표만 반환 (실시간 집계) - 캠프 ENDED: 캠프 종료 시 배치 생성된 최종 리포트 반환 (재계산 없음)  클라이언트는 응답 하나를 §1.1(캠프)/§1.2(코너)/§1.4(조) 구간으로 나눠 탭별로 렌더링한다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getFReportsAnalyticsApi();

try {
    final response = api.reportsCurrentGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling FReportsAnalyticsApi->reportsCurrentGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CampReport**](CampReport.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportsGeneratePost**
> reportsGeneratePost(reportsGeneratePostRequest)

캠프 결과 리포트 배치 생성 (내부용)

캠프 결과 리포트를 배치로 생성한다. 이 API는 `POST /camps/{id}/end` 호출 시 서버 내부에서 자동 트리거되며, 관리자가 직접 호출할 일은 없다 (내부용). 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getFReportsAnalyticsApi();
final ReportsGeneratePostRequest reportsGeneratePostRequest = ; // ReportsGeneratePostRequest | 

try {
    api.reportsGeneratePost(reportsGeneratePostRequest);
} on DioException catch (e) {
    print('Exception when calling FReportsAnalyticsApi->reportsGeneratePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reportsGeneratePostRequest** | [**ReportsGeneratePostRequest**](ReportsGeneratePostRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reportsLiveSummaryGet**
> ReportsLiveSummaryGet200Response reportsLiveSummaryGet()

실시간 스냅샷 요약

현재 선택된 캠프의 실시간 요약 데이터를 조회한다. 코너/트랙의 현재 상태 중심의 가벼운 집계만 포함 (전체 기간 통계 아님). SSE `corners_updated`/`groups_updated` 알림 수신 시 재조회 및 대시보드 30초 주기 폴백 재조회에 사용된다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getFReportsAnalyticsApi();

try {
    final response = api.reportsLiveSummaryGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling FReportsAnalyticsApi->reportsLiveSummaryGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReportsLiveSummaryGet200Response**](ReportsLiveSummaryGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

