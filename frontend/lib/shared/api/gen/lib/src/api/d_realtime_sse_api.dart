//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:cornermon_api_gen/src/api_util.dart';
import 'package:cornermon_api_gen/src/model/error_response.dart';
import 'package:cornermon_api_gen/src/model/sse_event.dart';

class DRealtimeSSEApi {

  final Dio _dio;

  final Serializers _serializers;

  const DRealtimeSSEApi(this._dio, this._serializers);

  /// 관리자 대시보드 SSE 스트림 (얇은 변경 알림)
  /// 관리자 대시보드용 SSE(Server-Sent Events) 스트림에 연결한다. §technical-design.md 2.3의 하이브리드 알림+풀 모델을 따른다 — **이 스트림은 데이터를 나르지 않는다.**  **이벤트 흐름**: 1. 화면 진입 시: 클라이언트가 REST로 초기 전체 조회 (&#x60;GET /corners&#x60;, &#x60;GET /groups&#x60;, &#x60;GET /tracks&#x60;,    &#x60;GET /camps/{id}&#x60;, &#x60;GET /device-registrations&#x60;, &#x60;GET /messages/broadcast&#x60; 등)를 직접 수행한다.    서버는 연결 시점에 별도 스냅샷을 push하지 않는다. 2. 상태 변경마다: &#x60;{event: &lt;type&gt;, data: {scope}}&#x60; 형태의 알림만 push — 알림을 받으면 그 &#x60;scope&#x60;에    대응하는 REST를 재조회한다. 3. 15~20초 주기: SSE 하트비트 (&#x60;:&#x60; 주석 라인) 4. 안전망: 알림을 놓쳐도 정합이 깨지지 않도록 대시보드는 30초 주기로 REST 전체 재조회도 병행한다.  **수신 알림 타입 → 재조회 매핑**: - &#x60;tracks_updated&#x60; (scope: &#x60;camp&#x60;) → &#x60;GET /tracks&#x60; — 트랙 생성/삭제/교체 - &#x60;corners_updated&#x60; (scope: &#x60;camp&#x60;) → &#x60;GET /corners&#x60; — 코너 규칙 변경, 방문 시작/종료로 인한 코너 운영상태·병목 변화 - &#x60;groups_updated&#x60; (scope: &#x60;camp&#x60;) → &#x60;GET /groups&#x60; — 조 순회표 변화(방문 시작/종료) - &#x60;camp_updated&#x60; (scope: &#x60;camp&#x60;) → &#x60;GET /camps/{id}&#x60; — 캠프 시작/종료 - &#x60;messages_changed&#x60; (scope: &#x60;broadcast&#x60;) → &#x60;GET /messages/broadcast&#x60; — 공지 발송 - &#x60;device_registration_updated&#x60; (scope: &#x60;camp&#x60;) → &#x60;GET /device-registrations&#x60; — 기기 등록/승인/거절/회수 - &#x60;lockout_alert&#x60; (scope: &#x60;device:{deviceId}&#x60;) → &#x60;GET /device-registrations&#x60; — PIN 5회 이상 실패 경고 
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SseEvent] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SseEvent>> eventsAdminGet({ 
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/events/admin';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AdminAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SseEvent? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(SseEvent),
      ) as SseEvent;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SseEvent>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// 진행자 앱 SSE 스트림 (얇은 변경 알림)
  /// 진행자 앱용 SSE 스트림. 자기 트랙 상태·공지·다이렉트 메시지에 대한 변경 알림만 수신한다. §technical-design.md 2.3의 하이브리드 알림+풀 모델을 따른다 — **이 스트림은 데이터를 나르지 않는다.**  **이벤트 흐름**: 1. 화면 진입 시: 클라이언트가 REST로 초기 조회(&#x60;GET /corners&#x60;로 자기 코너·트랙 상태,    &#x60;GET /tracks/{trackId}/visits/current&#x60;로 진행 중인 방문, &#x60;GET /messages/broadcast&#x60; +    &#x60;GET /tracks/{trackId}/messages&#x60;로 메시지 이력)를 직접 수행한다. 서버는 연결 시점에    별도 스냅샷을 push하지 않는다. 2. 상태 변경마다: &#x60;{event: &lt;type&gt;, data: {scope}}&#x60; 형태의 알림만 push. 3. 짧은 시간에 알림이 연달아 오면(메시지 연속 수신 등) 클라이언트는 매번 재조회하지 않도록    짧은 디바운스(예: 100ms)를 둔다.  **수신 알림 타입 → 재조회 매핑**: - &#x60;track_updated&#x60; (scope: &#x60;track:{trackId}&#x60;) → &#x60;GET /corners&#x60; + &#x60;GET /tracks/{trackId}/visits/current&#x60; — 방문 시작/종료로 인한 자기 트랙 상태 변경 - &#x60;messages_changed&#x60; (scope: &#x60;broadcast&#x60;) → &#x60;GET /messages/broadcast&#x60; — 공지 수신 - &#x60;messages_changed&#x60; (scope: &#x60;track:{trackId}&#x60;) → &#x60;GET /tracks/{trackId}/messages&#x60; — 다이렉트 메시지 수신 - &#x60;track_deleted&#x60; (scope: &#x60;track:{trackId}&#x60;) → 즉시 B1(로그인) 화면 전환 (트랙 삭제 또는 트랙 교체로 인한 세션 종료) - &#x60;session_revoked&#x60; (scope: &#x60;track:{trackId}&#x60;) → 즉시 B1 전환 (관리자 강제 로그아웃) - &#x60;camp_ended&#x60; (scope: &#x60;camp&#x60;) → 즉시 B1 전환 (캠프 종료)  **세션 강제 종료 알림**(&#x60;track_deleted&#x60; / &#x60;session_revoked&#x60; / &#x60;camp_ended&#x60;)이 오면 클라이언트는 REST 재조회 없이 BUSY 여부와 무관하게 즉시 B1 화면으로 전환하고 원인별 안내 문구를 표시한다. 
  ///
  /// Parameters:
  /// * [trackId] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SseEvent] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SseEvent>> eventsTrackTrackIdGet({ 
    required String trackId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/events/track/{trackId}'.replaceAll('{' r'trackId' '}', encodeQueryParameter(_serializers, trackId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'TrackAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SseEvent? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(SseEvent),
      ) as SseEvent;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SseEvent>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
