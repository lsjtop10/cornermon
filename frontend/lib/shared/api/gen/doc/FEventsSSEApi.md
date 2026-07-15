# cornermon_api_gen.api.FEventsSSEApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiV1CampsCampIdEventsAdminGet**](FEventsSSEApi.md#apiv1campscampideventsadminget) | **GET** /api/v1/camps/{campId}/events/admin | Admin SSE Stream
[**apiV1EventsTrackTrackIdGet**](FEventsSSEApi.md#apiv1eventstracktrackidget) | **GET** /api/v1/events/track/{trackId} | Track SSE Stream


# **apiV1CampsCampIdEventsAdminGet**
> SSENotification apiV1CampsCampIdEventsAdminGet(campId)

Admin SSE Stream

관리자용 실시간 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\"event\":\"tracks_updated\",\"scope\":{\"kind\":\"camp\"}} 입니다. 이벤트에는 상태 스냅샷이 포함되지 않으므로, 수신한 클라이언트는 해당 REST API로 최신 상태를 조회해야 합니다. 이벤트는 best-effort 알림이므로 서버는 유실된 메시지를 저장·재전송하지 않습니다. 버퍼가 찬 연결은 종료되며, 클라이언트는 재연결 후 REST API로 최신 상태를 다시 조회해야 합니다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: AdminAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('AdminAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getFEventsSSEApi();
final String campId = campId_example; // String | 캠프 ID

try {
    final response = api.apiV1CampsCampIdEventsAdminGet(campId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FEventsSSEApi->apiV1CampsCampIdEventsAdminGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **campId** | **String**| 캠프 ID | 

### Return type

[**SSENotification**](SSENotification.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiV1EventsTrackTrackIdGet**
> SSENotification apiV1EventsTrackTrackIdGet(trackId)

Track SSE Stream

트랙 진행자용 실시간 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\"event\":\"track_updated\",\"scope\":{\"kind\":\"track\",\"trackId\":\"track-id\"}} 입니다. 이벤트에는 상태 스냅샷이 포함되지 않으므로, 수신한 클라이언트는 해당 REST API로 최신 상태를 조회해야 합니다. 이벤트는 best-effort 알림이므로 서버는 유실된 메시지를 저장·재전송하지 않습니다. 버퍼가 찬 연결은 종료되며, 클라이언트는 재연결 후 REST API로 최신 상태를 다시 조회해야 합니다.

### Example
```dart
import 'package:cornermon_api_gen/api.dart';
// TODO Configure API key authorization: TrackAuth
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('TrackAuth').apiKeyPrefix = 'Bearer';

final api = CornermonApiGen().getFEventsSSEApi();
final String trackId = trackId_example; // String | 트랙 ID

try {
    final response = api.apiV1EventsTrackTrackIdGet(trackId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FEventsSSEApi->apiV1EventsTrackTrackIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**| 트랙 ID | 

### Return type

[**SSENotification**](SSENotification.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

