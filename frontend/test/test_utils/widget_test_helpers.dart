import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// 위젯 테스트 공통 뼈대 — ProviderScope override + MaterialApp(home: child).
Widget buildTestable(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(overrides: overrides, child: MaterialApp(home: child));

/// 순수 provider/notifier 단위 테스트용 컨테이너.
/// dispose는 호출부 책임(`addTearDown(container.dispose)` 등) — 여기서는 생성만 한다.
ProviderContainer buildContainer({List<Override> overrides = const []}) =>
    ProviderContainer(overrides: overrides);

/// 실제 네트워크 없이 고정 응답을 돌려주는 Dio.
/// `apiClientProvider`를 override할 때 사용 — [responder]가 돌려준 Map을 그대로 JSON 바디로 인코딩한다.
/// 상태코드는 200 고정(에러 응답 테스트가 필요해지면 그때 파라미터를 추가한다).
Dio buildFakeDio(Map<String, dynamic> Function(RequestOptions options) responder) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));
  dio.httpClientAdapter = _FakeHttpClientAdapter(responder);
  return dio;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._responder);

  final Map<String, dynamic> Function(RequestOptions options) _responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Dio 기본 트랜스포머가 JSON으로 디코드하도록 content-type을 명시한다.
    final body = jsonEncode(_responder(options));
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
