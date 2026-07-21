// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:cornermon_api_gen/src/api_util.dart';
import 'package:cornermon_api_gen/src/model/sse_notification.dart';

class FEventsSSEApi {

  final Dio _dio;

  final Serializers _serializers;

  const FEventsSSEApi(this._dio, this._serializers);

  /// Admin SSE Stream
  /// 관리자용 best-effort 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\&quot;event\&quot;:\&quot;tracks_updated\&quot;,\&quot;scope\&quot;:{\&quot;kind\&quot;:\&quot;camp\&quot;}} 입니다. 이벤트에는 상태 스냅샷이 없으므로 수신한 관리자는 해당 REST API로 최신 상태를 조회합니다. &#x60;camp_ended&#x60;도 관리자는 REST 재조회할 수 있습니다. 서버는 유실된 메시지를 저장·재전송하지 않으며, 버퍼가 찬 연결은 종료됩니다. 재연결 후 REST API로 최신 상태를 다시 조회해야 합니다.
  ///
  /// Parameters:
  /// * [campId] - 캠프 ID
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SSENotification] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SSENotification>> apiV1CampsCampIdEventsAdminGet({ 
    required String campId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/camps/{campId}/events/admin'.replaceAll('{' r'campId' '}', encodeQueryParameter(_serializers, campId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'AdminAuth',
            'keyName': 'Authorization',
            'where': 'header',
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

    SSENotification? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(SSENotification),
      ) as SSENotification;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SSENotification>(
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

  /// Track SSE Stream
  /// 트랙 진행자용 best-effort 변경 알림 스트림입니다. 각 event의 data는 SSENotification JSON이며 예시는 {\&quot;event\&quot;:\&quot;track_updated\&quot;,\&quot;scope\&quot;:{\&quot;kind\&quot;:\&quot;track\&quot;,\&quot;trackId\&quot;:\&quot;track-id\&quot;}} 입니다. 일반 이벤트에는 상태 스냅샷이 없으므로 REST API로 최신 상태를 조회합니다. 단, &#x60;camp_ended&#x60;는 terminal event이므로 REST 재조회 없이 로컬 진행자 세션·기기 등록을 삭제하고 등록 화면으로 이동합니다. 이벤트 도착·순서는 판정 근거가 아니며, 일반 재조회가 SESSION_REVOKED/401로 실패하거나 SSE를 놓치면 GET /device-registrations/me의 status와 campStatus로 최종 복구합니다: APPROVED/ACTIVE는 PIN 세션만 종료, REVOKED/ENDED는 캠프 종료, REVOKED/그 외는 기기 신뢰 회수입니다. 서버는 유실된 메시지를 저장·재전송하지 않습니다.
  ///
  /// Parameters:
  /// * [trackId] - 트랙 ID
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SSENotification] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SSENotification>> apiV1EventsTrackTrackIdGet({ 
    required String trackId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/events/track/{trackId}'.replaceAll('{' r'trackId' '}', encodeQueryParameter(_serializers, trackId, const FullType(String)).toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'apiKey',
            'name': 'TrackAuth',
            'keyName': 'Authorization',
            'where': 'header',
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

    SSENotification? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(SSENotification),
      ) as SSENotification;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SSENotification>(
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
