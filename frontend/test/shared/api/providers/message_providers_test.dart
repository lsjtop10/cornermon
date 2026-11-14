import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';

/// 서버로 나간 `background` 쿼리 값만 기록하는 가짜 구현. 다른 메서드는 호출되지 않는다.
class _FakeMessageApi extends EMessageApi {
  _FakeMessageApi() : super(Dio(), serializers);

  final List<bool?> capturedBackground = [];

  @override
  Future<Response<BuiltList<Message>>> tracksTrackIdMessagesGet({
    required String trackId,
    bool? background,
    String? after,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    capturedBackground.add(background);
    return Response<BuiltList<Message>>(
      data: BuiltList<Message>(),
      requestOptions: RequestOptions(path: '/tracks/$trackId/messages'),
    );
  }
}

void main() {
  final trackId = TrackId('t1');

  test('ShouldRequestWithoutReadMarkingWhenPeekProviderIsRead', () async {
    // arrange
    final fakeApi = _FakeMessageApi();
    final container = ProviderContainer(
      overrides: [messageApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);

    // act
    await container.read(trackMessagePeekProvider(trackId).future);

    // assert
    expect(fakeApi.capturedBackground, [false]);
  });

  test('ShouldRequestWithReadMarkingWhenThreadProviderIsRead', () async {
    // arrange
    final fakeApi = _FakeMessageApi();
    final container = ProviderContainer(
      overrides: [messageApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);

    // act
    await container.read(trackMessageThreadProvider(trackId).future);

    // assert
    expect(fakeApi.capturedBackground, [true]);
  });
}
