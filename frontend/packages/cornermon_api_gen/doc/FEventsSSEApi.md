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

관리자용 best-effort 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\"event\":\"tracks_updated\",\"scope\":{\"kind\":\"camp\"}} 입니다. 이벤트에는 상태 스냅샷이 없으므로 수신한 관리자는 해당 REST API로 최신 상태를 조회합니다. `camp_ended`도 관리자는 REST 재조회할 수 있습니다. 서버는 유실된 메시지를 저장·재전송하지 않으며, 버퍼가 찬 연결은 종료됩니다. 재연결 후 REST API로 최신 상태를 다시 조회해야 합니다.

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

트랙 진행자용 best-effort 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\"event\":\"track_updated\",\"scope\":{\"kind\":\"track\",\"trackId\":\"track-id\"}} 입니다. 일반 이벤트에는 상태 스냅샷이 없으므로 REST API로 최신 상태를 조회합니다. 단, `camp_ended`는 terminal event이므로 REST 재조회 없이 로컬 진행자 세션·기기 등록을 삭제하고 등록 화면으로 이동합니다. 이벤트 도착·순서는 판정 근거가 아니며, 일반 재조회가 SESSION_REVOKED/401로 실패하거나 SSE를 놓치면 GET /device-registrations/me의 status와 campStatus로 최종 복구합니다: APPROVED/ACTIVE는 PIN 세션만 종료, REVOKED/ENDED는 캠프 종료, REVOKED/그 외는 기기 신뢰 회수입니다. 서버는 유실된 메시지를 저장·재전송하지 않습니다.

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

