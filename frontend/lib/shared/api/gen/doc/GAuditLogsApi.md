# cornermon_api_gen.api.GAuditLogsApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**auditLogsGet**](GAuditLogsApi.md#auditlogsget) | **GET** /audit-logs | 감사 로그 조회


# **auditLogsGet**
> AuditLogPageResponse auditLogsGet(actor, action, result, campId, limit, before)

감사 로그 조회

시스템에서 발생한 중요 행위(인증, 방문, 예외 처리 등)의 감사 로그를 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getGAuditLogsApi();
final String actor = actor_example; // String | 행위자 부분 일치
final String action = action_example; // String | 행위 종류 정확히 일치
final String result = result_example; // String | 처리 결과
final String campId = campId_example; // String | 캠프 ID로 범위 제한
final int limit = 56; // int | 조회 개수
final String before = before_example; // String | 이전 응답의 불투명 nextCursor

try {
    final response = api.auditLogsGet(actor, action, result, campId, limit, before);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GAuditLogsApi->auditLogsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actor** | **String**| 행위자 부분 일치 | [optional] 
 **action** | **String**| 행위 종류 정확히 일치 | [optional] 
 **result** | **String**| 처리 결과 | [optional] 
 **campId** | **String**| 캠프 ID로 범위 제한 | [optional] 
 **limit** | **int**| 조회 개수 | [optional] [default to 50]
 **before** | **String**| 이전 응답의 불투명 nextCursor | [optional] 

### Return type

[**AuditLogPageResponse**](AuditLogPageResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

