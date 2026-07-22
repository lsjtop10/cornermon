import 'package:dio/dio.dart';

/// 공통 Dio의 인증·오류 처리 정책을 재사용하면서 SSE 요청에만 전송 timeout을 적용한다.
class SseTransport {
  SseTransport(this._dio, {required this.receiveTimeout});

  final Dio _dio;
  final Duration receiveTimeout;

  Future<Response<ResponseBody>> open(
    String path, {
    required CancelToken cancelToken,
  }) {
    return _dio.get<ResponseBody>(
      path,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: receiveTimeout,
        headers: const {'Accept': 'text/event-stream'},
      ),
    );
  }
}
