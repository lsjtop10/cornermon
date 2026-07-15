# cornermon_api_gen.api.EMessageApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**campsCampIdMessagesBroadcastGet**](EMessageApi.md#campscampidmessagesbroadcastget) | **GET** /camps/{campId}/messages/broadcast | 발송된 공지사항 목록
[**campsCampIdMessagesBroadcastPost**](EMessageApi.md#campscampidmessagesbroadcastpost) | **POST** /camps/{campId}/messages/broadcast | 전체 공지 발송
[**messagesBroadcastIdReadPost**](EMessageApi.md#messagesbroadcastidreadpost) | **POST** /messages/broadcast/{id}/read | 공지사항 읽음 처리
[**messagesBroadcastIdReceiptsGet**](EMessageApi.md#messagesbroadcastidreceiptsget) | **GET** /messages/broadcast/{id}/receipts | 공지사항 수신 확인 현황
[**tracksTrackIdMessagesGet**](EMessageApi.md#trackstrackidmessagesget) | **GET** /tracks/{trackId}/messages | 트랙별 메시지 내역 조회 (진행자)
[**tracksTrackIdMessagesPost**](EMessageApi.md#trackstrackidmessagespost) | **POST** /tracks/{trackId}/messages | 다이렉트 메시지 발송
[**tracksTrackIdMessagesUnreadCountGet**](EMessageApi.md#trackstrackidmessagesunreadcountget) | **GET** /tracks/{trackId}/messages/unread-count | 트랙 미확인 다이렉트 메시지 개수 조회


# **campsCampIdMessagesBroadcastGet**
> BuiltList<MessageResponse> campsCampIdMessagesBroadcastGet(campId)

발송된 공지사항 목록

관리자가 보낸 BROADCAST 메시지들의 목록을 조회한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getEMessageApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.campsCampIdMessagesBroadcastGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessageApi->campsCampIdMessagesBroadcastGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**BuiltList&lt;MessageResponse&gt;**](MessageResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **campsCampIdMessagesBroadcastPost**
> MessageResponse campsCampIdMessagesBroadcastPost(campId, request)

전체 공지 발송

모든 활성 트랙에 BROADCAST 메시지를 보낸다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getEMessageApi();
final String campId = campId_example; // String | 캠프 ID
final BroadcastMessageRequest request = ; // BroadcastMessageRequest | 메시지 내용

try {
    final response = api.campsCampIdMessagesBroadcastPost(campId, request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessageApi->campsCampIdMessagesBroadcastPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 
 **request** | [**BroadcastMessageRequest**](BroadcastMessageRequest.md)| 메시지 내용 | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **messagesBroadcastIdReadPost**
> messagesBroadcastIdReadPost(id)

공지사항 읽음 처리

트랙 진행자가 공지사항을 확인(읽음) 처리한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getEMessageApi();
final String id = id_example; // String | 메시지 ID

try {
    api.messagesBroadcastIdReadPost(id);
} on DioException catch (e) {
    print('Exception when calling EMessageApi->messagesBroadcastIdReadPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 메시지 ID | 

### Return type

void (empty response body)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **messagesBroadcastIdReceiptsGet**
> BuiltList<BroadcastReceiptResponse> messagesBroadcastIdReceiptsGet(id)

공지사항 수신 확인 현황

특정 공지사항에 대해 트랙들의 수신/읽음 상태를 확인한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getEMessageApi();
final String id = id_example; // String | 메시지 ID

try {
    final response = api.messagesBroadcastIdReceiptsGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessageApi->messagesBroadcastIdReceiptsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 메시지 ID | 

### Return type

[**BuiltList&lt;BroadcastReceiptResponse&gt;**](BroadcastReceiptResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdMessagesGet**
> BuiltList<MessageResponse> tracksTrackIdMessagesGet(trackId, background, after)

트랙별 메시지 내역 조회 (진행자)

트랙 진행자가 자신의 트랙과 관련된 DIRECT 메시지 내역을 조회한다(GitHub Issue #69, 구현 예정).

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getEMessageApi();
final String trackId = trackId_example; // String | 트랙 ID
final bool background = true; // bool | true면 상대측이 보낸 미확인 메시지를 읽음 처리
final String after = after_example; // String | RFC3339 UTC 이후 메시지만 반환

try {
    final response = api.tracksTrackIdMessagesGet(trackId, background, after);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessageApi->tracksTrackIdMessagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 
 **background** | **bool**| true면 상대측이 보낸 미확인 메시지를 읽음 처리 | [optional] 
 **after** | **String**| RFC3339 UTC 이후 메시지만 반환 | [optional] 

### Return type

[**BuiltList&lt;MessageResponse&gt;**](MessageResponse.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdMessagesPost**
> MessageResponse tracksTrackIdMessagesPost(trackId, request)

다이렉트 메시지 발송

관리자가 특정 트랙에, 또는 특정 트랙이 관리자에게 DIRECT 메시지를 발송한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getEMessageApi();
final String trackId = trackId_example; // String | 트랙 ID
final DirectMessageRequest request = ; // DirectMessageRequest | 메시지 내용

try {
    final response = api.tracksTrackIdMessagesPost(trackId, request);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessageApi->tracksTrackIdMessagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 
 **request** | [**DirectMessageRequest**](DirectMessageRequest.md)| 메시지 내용 | 

### Return type

[**MessageResponse**](MessageResponse.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdMessagesUnreadCountGet**
> UnreadCountResponse tracksTrackIdMessagesUnreadCountGet(trackId)

트랙 미확인 다이렉트 메시지 개수 조회

호출자(관리자 또는 진행자) 기준으로 상대측이 보낸 미확인 메시지 개수를 반환한다(GitHub Issue #69, 구현 예정).

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getEMessageApi();
final String trackId = trackId_example; // String | 트랙 ID

try {
    final response = api.tracksTrackIdMessagesUnreadCountGet(trackId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessageApi->tracksTrackIdMessagesUnreadCountGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 

### Return type

[**UnreadCountResponse**](UnreadCountResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

