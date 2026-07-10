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
> AuditLogsGet200Response auditLogsGet(actor, action, result, sort, order, limit, before)

감사 로그 조회

인증 성공/실패, 스캔, 규칙 변경, 기기 승인/철회, 트랙 관리 등의 감사 로그를 조회한다. 메시지 통신 내역은 감사 대상에서 제외. 필터링·정렬을 쿼리 파라미터로 지정해 서버에서 처리한다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getGAuditLogsApi();
final String actor = actor_example; // String | 행위자 부분 일치 검색
final String action = action_example; // String | 행위 종류 필터 (예: TRACK_CREATED, PIN_LOGIN_FAILED)
final String result = result_example; // String | 성공/실패 필터
final String sort = sort_example; // String | 정렬 기준
final String order = order_example; // String | 
final int limit = 56; // int | 
final DateTime before = 2013-10-20T19:20:30+01:00; // DateTime | 커서 기반 페이지네이션: 이 시각 이전 항목 조회

try {
    final response = api.auditLogsGet(actor, action, result, sort, order, limit, before);
    print(response);
} on DioException catch (e) {
    print('Exception when calling GAuditLogsApi->auditLogsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actor** | **String**| 행위자 부분 일치 검색 | [optional] 
 **action** | **String**| 행위 종류 필터 (예: TRACK_CREATED, PIN_LOGIN_FAILED) | [optional] 
 **result** | **String**| 성공/실패 필터 | [optional] 
 **sort** | **String**| 정렬 기준 | [optional] 
 **order** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **before** | **DateTime**| 커서 기반 페이지네이션: 이 시각 이전 항목 조회 | [optional] 

### Return type

[**AuditLogsGet200Response**](AuditLogsGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

