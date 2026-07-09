# cornermon_api_gen.api.CVisitScanFlowApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**groupsIdVisitsGet**](CVisitScanFlowApi.md#groupsidvisitsget) | **GET** /groups/{id}/visits | 특정 조의 전체 방문 이력
[**tracksTrackIdVisitsCurrentEndPost**](CVisitScanFlowApi.md#trackstrackidvisitscurrentendpost) | **POST** /tracks/{trackId}/visits/current/end | 현재 방문 종료 (조 퇴장)
[**tracksTrackIdVisitsCurrentGet**](CVisitScanFlowApi.md#trackstrackidvisitscurrentget) | **GET** /tracks/{trackId}/visits/current | 현재 진행 중인 방문 조회
[**tracksTrackIdVisitsStartPost**](CVisitScanFlowApi.md#trackstrackidvisitsstartpost) | **POST** /tracks/{trackId}/visits/start | 방문 시작 (조 입장)
[**visitsExceptionApprovePost**](CVisitScanFlowApi.md#visitsexceptionapprovepost) | **POST** /visits/exception-approve | 중복 방문 예외 승인


# **groupsIdVisitsGet**
> GroupsIdVisitsGet200Response groupsIdVisitsGet(id)

특정 조의 전체 방문 이력

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 조 ID

try {
    final response = api.groupsIdVisitsGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->groupsIdVisitsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 조 ID | 

### Return type

[**GroupsIdVisitsGet200Response**](GroupsIdVisitsGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdVisitsCurrentEndPost**
> VisitSummary tracksTrackIdVisitsCurrentEndPost(trackId)

현재 방문 종료 (조 퇴장)

진행 중인 방문을 종료 처리한다. (화면의 종료 확인 2회 탭) 재스캔 없이 트랙에 유일하게 정해진 IN_PROGRESS 방문을 종료한다. 소요시간 및 목표시간 편차(deviation)를 계산해 저장한다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tracksTrackIdVisitsCurrentEndPost(trackId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->tracksTrackIdVisitsCurrentEndPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**|  | 

### Return type

[**VisitSummary**](VisitSummary.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdVisitsCurrentGet**
> VisitSummary tracksTrackIdVisitsCurrentGet(trackId)

현재 진행 중인 방문 조회

진행자 앱 화면 새로고침용. 현재 트랙에서 IN_PROGRESS 상태인 방문을 반환한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tracksTrackIdVisitsCurrentGet(trackId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->tracksTrackIdVisitsCurrentGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**|  | 

### Return type

[**VisitSummary**](VisitSummary.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdVisitsStartPost**
> VisitSummary tracksTrackIdVisitsStartPost(trackId, tracksTrackIdVisitsStartPostRequest)

방문 시작 (조 입장)

진행자가 조의 입장을 처리한다. - **QR 스캔**: `qrToken` 제공 - **수동 처리**: `groupId` + `method: \"MANUAL\"` 제공 (QR 배지 손상 시)  **거부 조건**: - 트랙이 이미 BUSY (동시 진행 조 있음) - 해당 조가 이미 이 코너를 COMPLETED - 해당 조가 다른 코너에서 IN_PROGRESS 상태 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final TracksTrackIdVisitsStartPostRequest tracksTrackIdVisitsStartPostRequest = ; // TracksTrackIdVisitsStartPostRequest | 

try {
    final response = api.tracksTrackIdVisitsStartPost(trackId, tracksTrackIdVisitsStartPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->tracksTrackIdVisitsStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**|  | 
 **tracksTrackIdVisitsStartPostRequest** | [**TracksTrackIdVisitsStartPostRequest**](TracksTrackIdVisitsStartPostRequest.md)|  | 

### Return type

[**VisitSummary**](VisitSummary.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **visitsExceptionApprovePost**
> visitsExceptionApprovePost(visitsExceptionApprovePostRequest)

중복 방문 예외 승인

중복 방문 금지 규칙의 예외를 관리자가 명시적으로 승인한다. 이후 해당 조의 해당 코너에서 재방문이 허용된다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getCVisitScanFlowApi();
final VisitsExceptionApprovePostRequest visitsExceptionApprovePostRequest = ; // VisitsExceptionApprovePostRequest | 

try {
    api.visitsExceptionApprovePost(visitsExceptionApprovePostRequest);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->visitsExceptionApprovePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **visitsExceptionApprovePostRequest** | [**VisitsExceptionApprovePostRequest**](VisitsExceptionApprovePostRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

