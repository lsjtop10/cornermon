# cornermon_api_gen.api.CVisitScanFlowApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**tracksTrackIdCornerGet**](CVisitScanFlowApi.md#trackstrackidcornerget) | **GET** /tracks/{trackId}/corner | 진행자 코너 조회
[**tracksTrackIdGroupsGet**](CVisitScanFlowApi.md#trackstrackidgroupsget) | **GET** /tracks/{trackId}/groups | 진행자 수동 체크인용 조 목록 조회
[**tracksTrackIdVisitsCurrentEndPost**](CVisitScanFlowApi.md#trackstrackidvisitscurrentendpost) | **POST** /tracks/{trackId}/visits/current/end | 현재 방문 종료 (조 퇴장)
[**tracksTrackIdVisitsCurrentGet**](CVisitScanFlowApi.md#trackstrackidvisitscurrentget) | **GET** /tracks/{trackId}/visits/current | 현재 진행 중인 방문 상태 조회
[**tracksTrackIdVisitsStartPost**](CVisitScanFlowApi.md#trackstrackidvisitsstartpost) | **POST** /tracks/{trackId}/visits/start | 방문 시작 (조 입장)


# **tracksTrackIdCornerGet**
> CornerResponse tracksTrackIdCornerGet(trackId)

진행자 코너 조회

인증된 진행자(TrackAuth)의 트랙이 속한 코너의 핵심 정보를 조회한다. 세션의 트랙과 path trackId가 일치해야 한다. 다른 트랙의 활성 목록·병목 지표 등 관리자 전용 정보는 포함하지 않는다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = trackId_example; // String | 트랙 ID

try {
    final response = api.tracksTrackIdCornerGet(trackId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->tracksTrackIdCornerGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 

### Return type

[**CornerResponse**](CornerResponse.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdGroupsGet**
> BuiltList<GroupResponse> tracksTrackIdGroupsGet(trackId)

진행자 수동 체크인용 조 목록 조회

인증된 진행자의 트랙이 속한 캠프의 조 목록을 반환한다. 세션의 트랙과 path trackId가 일치해야 한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = trackId_example; // String | 트랙 ID

try {
    final response = api.tracksTrackIdGroupsGet(trackId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->tracksTrackIdGroupsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 

### Return type

[**BuiltList&lt;GroupResponse&gt;**](GroupResponse.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdVisitsCurrentEndPost**
> VisitSummaryResponse tracksTrackIdVisitsCurrentEndPost(trackId)

현재 방문 종료 (조 퇴장)

진행 중인 방문을 종료 처리한다. (화면의 종료 확인 2회 탭)

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = trackId_example; // String | 트랙 ID

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
 **trackId** | **String**| 트랙 ID | 

### Return type

[**VisitSummaryResponse**](VisitSummaryResponse.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdVisitsCurrentGet**
> VisitSummaryResponse tracksTrackIdVisitsCurrentGet(trackId)

현재 진행 중인 방문 상태 조회

스캐너 앱이 크래시되거나 새로고침 되었을 때, 현재 트랙에서 진행 중인 방문이 있는지 확인.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = trackId_example; // String | 트랙 ID

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
 **trackId** | **String**| 트랙 ID | 

### Return type

[**VisitSummaryResponse**](VisitSummaryResponse.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdVisitsStartPost**
> VisitSummaryResponse tracksTrackIdVisitsStartPost(trackId, request)

방문 시작 (조 입장)

진행자가 조의 입장을 처리한다. QR 스캔 또는 수동 처리.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getCVisitScanFlowApi();
final String trackId = trackId_example; // String | 트랙 ID
final VisitStartRequest request = ; // VisitStartRequest | 입장 방식 및 페이로드

try {
    final response = api.tracksTrackIdVisitsStartPost(trackId, request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CVisitScanFlowApi->tracksTrackIdVisitsStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 
 **request** | [**VisitStartRequest**](VisitStartRequest.md)| 입장 방식 및 페이로드 | 

### Return type

[**VisitSummaryResponse**](VisitSummaryResponse.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

