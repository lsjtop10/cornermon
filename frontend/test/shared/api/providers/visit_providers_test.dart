import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';

/// CVisitScanFlowApi는 생성 코드(concrete class)라 인터페이스가 아니지만,
/// 테스트에 필요한 3개 메서드만 override하고 나머지는 실제 구현을 그대로 상속한다(호출되지 않음).
class _FakeVisitScanFlowApi extends CVisitScanFlowApi {
  _FakeVisitScanFlowApi() : super(Dio(), serializers);

  VisitSummary? currentVisitData;
  VisitSummary? startVisitData;
  VisitSummary? endVisitData;

  String? capturedTrackId;
  VisitStartRequest? capturedStartRequest;

  @override
  Future<Response<VisitSummary>> tracksTrackIdVisitsCurrentGet({
    required String trackId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    capturedTrackId = trackId;
    return Response<VisitSummary>(
      data: currentVisitData,
      requestOptions: RequestOptions(path: '/tracks/$trackId/visits/current'),
    );
  }

  @override
  Future<Response<VisitSummary>> tracksTrackIdVisitsStartPost({
    required String trackId,
    required VisitStartRequest request,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    capturedTrackId = trackId;
    capturedStartRequest = request;
    return Response<VisitSummary>(
      data: startVisitData,
      requestOptions: RequestOptions(path: '/tracks/$trackId/visits/start'),
    );
  }

  @override
  Future<Response<VisitSummary>> tracksTrackIdVisitsCurrentEndPost({
    required String trackId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    capturedTrackId = trackId;
    return Response<VisitSummary>(
      data: endVisitData,
      requestOptions: RequestOptions(path: '/tracks/$trackId/visits/current/end'),
    );
  }
}

VisitSummary _buildVisitSummary({
  String id = 'visit-1',
  VisitStatus status = VisitStatus.IN_PROGRESS,
}) {
  return VisitSummary(
    (b) => b
      ..id = id
      ..groupId = 'group-1'
      ..cornerId = 'corner-1'
      ..trackId = 'track-1'
      ..status = status
      ..startedAt = DateTime.utc(2026, 7, 11, 10, 0, 0),
  );
}

void main() {
  final trackId = TrackId('track-1');

  test('ShouldReturnNullWhenNoCurrentVisit', () async {
    // arrange
    final fakeApi = _FakeVisitScanFlowApi();
    final container = ProviderContainer(
      overrides: [visitScanFlowApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);

    // act
    final result = await container.read(currentVisitProvider(trackId).future);

    // assert
    expect(result, isNull);
    expect(fakeApi.capturedTrackId, 'track-1');
  });

  test('ShouldReturnVisitSummaryWhenCurrentVisitExists', () async {
    // arrange
    final visit = _buildVisitSummary();
    final fakeApi = _FakeVisitScanFlowApi()..currentVisitData = visit;
    final container = ProviderContainer(
      overrides: [visitScanFlowApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);

    // act
    final result = await container.read(currentVisitProvider(trackId).future);

    // assert
    expect(result, same(visit));
  });

  test('ShouldStartVisitByQr', () async {
    // arrange
    final visit = _buildVisitSummary();
    final fakeApi = _FakeVisitScanFlowApi()..startVisitData = visit;
    final container = ProviderContainer(
      overrides: [visitScanFlowApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(visitActionsProvider(trackId).notifier);

    // act
    final result = await notifier.startByQr('qr-token-abc');

    // assert
    expect(result, same(visit));
    expect(fakeApi.capturedTrackId, 'track-1');
    expect(fakeApi.capturedStartRequest!.qrToken, 'qr-token-abc');
  });

  test('ShouldStartVisitManually', () async {
    // arrange
    final visit = _buildVisitSummary();
    final fakeApi = _FakeVisitScanFlowApi()..startVisitData = visit;
    final container = ProviderContainer(
      overrides: [visitScanFlowApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(visitActionsProvider(trackId).notifier);
    final groupId = GroupId('group-9');

    // act
    final result = await notifier.startManual(groupId);

    // assert
    expect(result, same(visit));
    expect(fakeApi.capturedStartRequest!.groupId, 'group-9');
    expect(fakeApi.capturedStartRequest!.method, VisitStartRequestMethodEnum.MANUAL);
  });

  test('ShouldEndCurrentVisit', () async {
    // arrange
    final visit = _buildVisitSummary(status: VisitStatus.COMPLETED);
    final fakeApi = _FakeVisitScanFlowApi()..endVisitData = visit;
    final container = ProviderContainer(
      overrides: [visitScanFlowApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(visitActionsProvider(trackId).notifier);

    // act
    final result = await notifier.endCurrent();

    // assert
    expect(result, same(visit));
    expect(fakeApi.capturedTrackId, 'track-1');
  });

  test('ShouldThrowWhenStartVisitReturnsNullData', () async {
    // arrange
    final fakeApi = _FakeVisitScanFlowApi(); // startVisitData 미설정 -> null
    final container = ProviderContainer(
      overrides: [visitScanFlowApiProvider.overrideWithValue(fakeApi)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(visitActionsProvider(trackId).notifier);

    // act & assert
    await expectLater(notifier.startByQr('qr-x'), throwsA(isA<Exception>()));
  });
}
