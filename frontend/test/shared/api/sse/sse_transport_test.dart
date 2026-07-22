import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/shared/api/sse/sse_transport.dart';

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? options;

  @override
  Future<ResponseBody> fetch(
    RequestOptions requestOptions,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    options = requestOptions;
    return ResponseBody(Stream<Uint8List>.empty(), 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('ShouldOverrideSharedReceiveTimeoutWhenOpeningSseStream', () async {
    // arrange
    final adapter = _CapturingAdapter();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://test.local',
        receiveTimeout: const Duration(seconds: 5),
      ),
    )..httpClientAdapter = adapter;
    final transport = SseTransport(
      dio,
      receiveTimeout: const Duration(seconds: 45),
    );

    // act
    await transport.open('/events/track/track-1', cancelToken: CancelToken());

    // assert
    expect(adapter.options?.receiveTimeout, const Duration(seconds: 45));
    expect(adapter.options?.responseType, ResponseType.stream);
    final accept = adapter.options?.headers.entries
        .firstWhere((entry) => entry.key.toLowerCase() == 'accept')
        .value;
    expect(accept, 'text/event-stream');
  });
}
