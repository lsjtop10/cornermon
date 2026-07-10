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

  /// 관리자 대시보드 SSE 스트림
  /// 관리자 대시보드용 SSE(Server-Sent Events) 스트림에 연결한다.  **이벤트 흐름**: 1. (재)연결 직후: &#x60;event: snapshot&#x60; — 전체 코너/트랙/조 현재 상태 스냅샷 전송 2. 상태 변경마다: 해당 이벤트 타입으로 스냅샷 push 3. 15~20초 주기: SSE 하트비트 (&#x60;:&#x60; 주석 라인)  **수신 이벤트 타입**: - &#x60;snapshot&#x60;: 전체 상태 스냅샷 - &#x60;visit.started&#x60; / &#x60;visit.ended&#x60;: 방문 시작/종료 - &#x60;track.created&#x60; / &#x60;track.deleted&#x60; / &#x60;track.replaced&#x60;: 트랙 생명주기 - &#x60;corner.updated&#x60;: 코너 규칙 변경 - &#x60;camp.started&#x60; / &#x60;camp.ended&#x60;: 캠프 상태 전이 - &#x60;message.broadcast&#x60;: 공지 발송 - &#x60;device.approved&#x60;: 기기 승인 완료 - &#x60;lockout.alert&#x60;: PIN 5회 이상 실패 경고 
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

  /// 진행자 앱 SSE 스트림
  /// 진행자 앱용 SSE 스트림. 자기 트랙 상태, 공지, 다이렉트 메시지를 수신한다.  **수신 이벤트 타입**: - &#x60;snapshot&#x60;: 트랙/코너/현재방문 스냅샷 - &#x60;visit.started&#x60; / &#x60;visit.ended&#x60;: 방문 상태 변경 - &#x60;message.broadcast&#x60;: 공지 수신 - &#x60;message.direct&#x60;: 다이렉트 메시지 수신 - &#x60;track.replaced&#x60;: 트랙 교체 — 새 세션 정보 전달 - &#x60;track.deleted&#x60;: 트랙 삭제 → 즉시 B1(로그인) 화면 전환 - &#x60;session.force_logout&#x60;: 강제 로그아웃 → 즉시 B1 전환 - &#x60;camp.ended&#x60;: 캠프 종료 → 즉시 B1 전환  **세션 강제 종료 이벤트**(&#x60;track.deleted&#x60; / &#x60;session.force_logout&#x60; / &#x60;camp.ended&#x60;)가 오면 클라이언트는 BUSY 여부와 무관하게 즉시 B1 화면으로 전환하고 원인별 안내 문구를 표시한다. 
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
