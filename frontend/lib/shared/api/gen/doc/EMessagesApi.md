# cornermon_api_gen.api.EMessagesApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**messagesBroadcastGet**](EMessagesApi.md#messagesbroadcastget) | **GET** /messages/broadcast | 공지 이력 조회
[**messagesBroadcastIdReadPost**](EMessagesApi.md#messagesbroadcastidreadpost) | **POST** /messages/broadcast/{id}/read | 공지 읽음 처리
[**messagesBroadcastIdReceiptsGet**](EMessagesApi.md#messagesbroadcastidreceiptsget) | **GET** /messages/broadcast/{id}/receipts | 공지별 트랙 읽음 현황
[**messagesBroadcastPost**](EMessagesApi.md#messagesbroadcastpost) | **POST** /messages/broadcast | 전체 공지 발송
[**tracksTrackIdMessagesGet**](EMessagesApi.md#trackstrackidmessagesget) | **GET** /tracks/{trackId}/messages | 트랙 다이렉트 메시지 이력
[**tracksTrackIdMessagesPost**](EMessagesApi.md#trackstrackidmessagespost) | **POST** /tracks/{trackId}/messages | 트랙 다이렉트 메시지 전송 (양방향)


# **messagesBroadcastGet**
> MessagesBroadcastGet200Response messagesBroadcastGet(limit, before)

공지 이력 조회

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getEMessagesApi();
final int limit = 56; // int | 
final DateTime before = 2013-10-20T19:20:30+01:00; // DateTime | 커서 기반 페이지네이션: 이 시각 이전 메시지 조회

try {
    final response = api.messagesBroadcastGet(limit, before);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessagesApi->messagesBroadcastGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] [default to 50]
 **before** | **DateTime**| 커서 기반 페이지네이션: 이 시각 이전 메시지 조회 | [optional] 

### Return type

[**MessagesBroadcastGet200Response**](MessagesBroadcastGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth), [TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **messagesBroadcastIdReadPost**
> messagesBroadcastIdReadPost(id)

공지 읽음 처리

해당 트랙이 공지를 읽음 처리한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getEMessagesApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.messagesBroadcastIdReadPost(id);
} on DioException catch (e) {
    print('Exception when calling EMessagesApi->messagesBroadcastIdReadPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **messagesBroadcastIdReceiptsGet**
> MessagesBroadcastIdReceiptsGet200Response messagesBroadcastIdReceiptsGet(id)

공지별 트랙 읽음 현황

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getEMessagesApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 공지 메시지 ID

try {
    final response = api.messagesBroadcastIdReceiptsGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessagesApi->messagesBroadcastIdReceiptsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| 공지 메시지 ID | 

### Return type

[**MessagesBroadcastIdReceiptsGet200Response**](MessagesBroadcastIdReceiptsGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **messagesBroadcastPost**
> Message messagesBroadcastPost(messagesBroadcastPostRequest)

전체 공지 발송

현재 ACTIVE 상태인 전체 트랙에 공지를 발송한다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getEMessagesApi();
final MessagesBroadcastPostRequest messagesBroadcastPostRequest = ; // MessagesBroadcastPostRequest | 

try {
    final response = api.messagesBroadcastPost(messagesBroadcastPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessagesApi->messagesBroadcastPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **messagesBroadcastPostRequest** | [**MessagesBroadcastPostRequest**](MessagesBroadcastPostRequest.md)|  | 

### Return type

[**Message**](Message.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdMessagesGet**
> MessagesBroadcastGet200Response tracksTrackIdMessagesGet(trackId, limit, before)

트랙 다이렉트 메시지 이력

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getEMessagesApi();
final String trackId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int limit = 56; // int | 
final DateTime before = 2013-10-20T19:20:30+01:00; // DateTime | 

try {
    final response = api.tracksTrackIdMessagesGet(trackId, limit, before);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessagesApi->tracksTrackIdMessagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**|  | 
 **limit** | **int**|  | [optional] [default to 50]
 **before** | **DateTime**|  | [optional] 

### Return type

[**MessagesBroadcastGet200Response**](MessagesBroadcastGet200Response.md)

### Authorization

[AdminAuth](../README.md#AdminAuth), [TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tracksTrackIdMessagesPost**
> Message tracksTrackIdMessagesPost(trackId, messagesBroadcastPostRequest)

트랙 다이렉트 메시지 전송 (양방향)

관리자 → 트랙 또는 트랙 → 관리자 방향으로 다이렉트 메시지를 전송한다. - ADMIN: 어느 트랙에든 전송 가능 - TRACK: 자기 트랙 스레드에만 전송 가능 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getEMessagesApi();
final String trackId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final MessagesBroadcastPostRequest messagesBroadcastPostRequest = ; // MessagesBroadcastPostRequest | 

try {
    final response = api.tracksTrackIdMessagesPost(trackId, messagesBroadcastPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EMessagesApi->tracksTrackIdMessagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**|  | 
 **messagesBroadcastPostRequest** | [**MessagesBroadcastPostRequest**](MessagesBroadcastPostRequest.md)|  | 

### Return type

[**Message**](Message.md)

### Authorization

[AdminAuth](../README.md#AdminAuth), [TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

