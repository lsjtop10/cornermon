# cornermon_api_gen.api.DRealtimeSSEApi

## Load the API package
```dart
import 'package:cornermon_api_gen/api.dart';
```

All URIs are relative to */api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**eventsAdminGet**](DRealtimeSSEApi.md#eventsadminget) | **GET** /events/admin | 관리자 대시보드 SSE 스트림
[**eventsTrackTrackIdGet**](DRealtimeSSEApi.md#eventstracktrackidget) | **GET** /events/track/{trackId} | 진행자 앱 SSE 스트림


# **eventsAdminGet**
> SseEvent eventsAdminGet()

관리자 대시보드 SSE 스트림

관리자 대시보드용 SSE(Server-Sent Events) 스트림에 연결한다.  **이벤트 흐름**: 1. (재)연결 직후: `event: snapshot` — 전체 코너/트랙/조 현재 상태 스냅샷 전송 2. 상태 변경마다: 해당 이벤트 타입으로 스냅샷 push 3. 15~20초 주기: SSE 하트비트 (`:` 주석 라인)  **수신 이벤트 타입**: - `snapshot`: 전체 상태 스냅샷 - `visit.started` / `visit.ended`: 방문 시작/종료 - `track.created` / `track.deleted` / `track.replaced`: 트랙 생명주기 - `corner.updated`: 코너 규칙 변경 - `camp.started` / `camp.ended`: 캠프 상태 전이 - `message.broadcast`: 공지 발송 - `device.approved`: 기기 승인 완료 - `lockout.alert`: PIN 5회 이상 실패 경고 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getDRealtimeSSEApi();

try {
    final response = api.eventsAdminGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DRealtimeSSEApi->eventsAdminGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SseEvent**](SseEvent.md)

### Authorization

[AdminAuth](../README.md#AdminAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsTrackTrackIdGet**
> SseEvent eventsTrackTrackIdGet(trackId)

진행자 앱 SSE 스트림

진행자 앱용 SSE 스트림. 자기 트랙 상태, 공지, 다이렉트 메시지를 수신한다.  **수신 이벤트 타입**: - `snapshot`: 트랙/코너/현재방문 스냅샷 - `visit.started` / `visit.ended`: 방문 상태 변경 - `message.broadcast`: 공지 수신 - `message.direct`: 다이렉트 메시지 수신 - `track.replaced`: 트랙 교체 — 새 세션 정보 전달 - `track.deleted`: 트랙 삭제 → 즉시 B1(로그인) 화면 전환 - `session.force_logout`: 강제 로그아웃 → 즉시 B1 전환 - `camp.ended`: 캠프 종료 → 즉시 B1 전환  **세션 강제 종료 이벤트**(`track.deleted` / `session.force_logout` / `camp.ended`)가 오면 클라이언트는 BUSY 여부와 무관하게 즉시 B1 화면으로 전환하고 원인별 안내 문구를 표시한다. 

### Example
```dart
import 'package:cornermon_api_gen/api.dart';

final api = CornermonApiGen().getDRealtimeSSEApi();
final String trackId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.eventsTrackTrackIdGet(trackId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DRealtimeSSEApi->eventsTrackTrackIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **trackId** | **String**|  | 

### Return type

[**SseEvent**](SseEvent.md)

### Authorization

[TrackAuth](../README.md#TrackAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

