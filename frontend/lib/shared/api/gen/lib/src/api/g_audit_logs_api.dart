//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:cornermon_api_gen/src/api_util.dart';
import 'package:cornermon_api_gen/src/model/audit_logs_get200_response.dart';
import 'package:cornermon_api_gen/src/model/error_response.dart';

class GAuditLogsApi {

  final Dio _dio;

  final Serializers _serializers;

  const GAuditLogsApi(this._dio, this._serializers);

  /// 감사 로그 조회
  /// 인증 성공/실패, 스캔, 규칙 변경, 기기 승인/철회, 트랙 관리 등의 감사 로그를 조회한다. 메시지 통신 내역은 감사 대상에서 제외. 필터링·정렬을 쿼리 파라미터로 지정해 서버에서 처리한다. 
  ///
  /// Parameters:
  /// * [actor] - 행위자 부분 일치 검색
  /// * [action] - 행위 종류 필터 (예: TRACK_CREATED, PIN_LOGIN_FAILED)
  /// * [result] - 성공/실패 필터
  /// * [sort] - 정렬 기준
  /// * [order] 
  /// * [limit] 
  /// * [before] - 커서 기반 페이지네이션: 이 시각 이전 항목 조회
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AuditLogsGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<AuditLogsGet200Response>> auditLogsGet({ 
    String? actor,
    String? action,
    String? result,
    String? sort,
    String? order,
    int? limit = 50,
    DateTime? before,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/audit-logs';
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

    final _queryParameters = <String, dynamic>{
      if (actor != null) r'actor': encodeQueryParameter(_serializers, actor, const FullType(String)),
      if (action != null) r'action': encodeQueryParameter(_serializers, action, const FullType(String)),
      if (result != null) r'result': encodeQueryParameter(_serializers, result, const FullType(String)),
      if (sort != null) r'sort': encodeQueryParameter(_serializers, sort, const FullType(String)),
      if (order != null) r'order': encodeQueryParameter(_serializers, order, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (before != null) r'before': encodeQueryParameter(_serializers, before, const FullType(DateTime)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    AuditLogsGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AuditLogsGet200Response),
      ) as AuditLogsGet200Response;

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<AuditLogsGet200Response>(
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
