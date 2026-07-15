import 'dart:async';

import 'package:cornermon/facilitator/features/qr_scan/qr_scan_screen.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../test_utils/widget_test_helpers.dart';

/// mobile_scanner의 실제 플랫폼 채널을 회피하기 위한 가짜 구현.
/// barcodesStream을 테스트에서 직접 제어해 onDetect 콜백을 트리거한다.
class _FakeMobileScannerPlatform extends MobileScannerPlatform {
  final StreamController<BarcodeCapture?> barcodesController =
      StreamController<BarcodeCapture?>.broadcast();
  int disposeCallCount = 0;

  @override
  Stream<BarcodeCapture?> get barcodesStream => barcodesController.stream;

  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();

  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async {
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(100, 100),
    );
  }

  @override
  Future<void> stop() async {}

  @override
  Widget buildCameraView() => const SizedBox.shrink();

  @override
  Future<void> dispose() async {
    disposeCallCount++;
  }
}

/// VisitActions fake — startByQr 호출 횟수를 세고, Completer로 완료 시점을 제어한다.
class _FakeVisitActions extends VisitActions {
  _FakeVisitActions({this.errorToThrow});

  final DioException? errorToThrow;
  int startByQrCallCount = 0;
  final List<Completer<VisitSummary>> _pendingResults = [];

  @override
  void build(TrackId trackId) {}

  @override
  Future<VisitSummary> startByQr(String qrToken) async {
    startByQrCallCount++;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    final completer = Completer<VisitSummary>();
    _pendingResults.add(completer);
    return completer.future;
  }
}

DioException _visitStartError(String code) {
  const path = '/tracks/track-1/visits/start';
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: Response<Object?>(
      requestOptions: RequestOptions(path: path),
      statusCode: 409,
      data: <String, dynamic>{'code': code},
    ),
  );
}

BarcodeCapture _capture(String rawValue) =>
    BarcodeCapture(barcodes: [Barcode(rawValue: rawValue)]);

void main() {
  final trackId = TrackId('track-1');
  late _FakeMobileScannerPlatform fakePlatform;

  setUp(() {
    fakePlatform = _FakeMobileScannerPlatform();
    MobileScannerPlatform.instance = fakePlatform;
  });

  TrackSessionAuthenticated buildAuthenticatedState() => TrackSessionAuthenticated(
        trackToken: 'test-token',
        track: Track(
          (b) => b
            ..id = trackId.value
            ..cornerId = 'corner-1'
            ..trackNo = 1
            ..status = TrackStatus.ACTIVE,
        ),
        corner: AuthTrackLoginPost200ResponseCorner(
          (b) => b
            ..id = 'corner-1'
            ..name = '입장',
        ),
      );

  testWidgets('ShouldCallStartByQrOnlyOnceWhenSameBarcodeDetectedTwiceQuickly', (tester) async {
    // arrange
    final fakeActions = _FakeVisitActions();
    await tester.pumpWidget(
      buildTestable(
        const QrScanScreen(),
        overrides: [
          trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
          visitActionsProvider(trackId).overrideWith(() => fakeActions),
        ],
      ),
    );
    await tester.pump();

    // act: 첫 startByQr가 아직 미완료(pending)인 상태에서 같은 바코드를 한 번 더 흘려보낸다.
    fakePlatform.barcodesController.add(_capture('qr-token-1'));
    await tester.pump();
    fakePlatform.barcodesController.add(_capture('qr-token-1'));
    await tester.pump();

    // assert: `_busy` 가드로 인해 1회만 호출된다.
    expect(fakeActions.startByQrCallCount, 1);
  });

  testWidgets('ShouldShowDuplicateVisitMessageWhenDuplicateVisitCodeReturned', (tester) async {
    // arrange
    final fakeActions = _FakeVisitActions(errorToThrow: _visitStartError('DUPLICATE_VISIT'));
    await tester.pumpWidget(
      buildTestable(
        const QrScanScreen(),
        overrides: [
          trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
          visitActionsProvider(trackId).overrideWith(() => fakeActions),
        ],
      ),
    );
    await tester.pump();

    // act
    fakePlatform.barcodesController.add(_capture('qr-token-1'));
    await tester.pump();
    await tester.pump();

    // assert
    expect(find.text('이미 완료된 코너입니다'), findsOneWidget);
  });

  testWidgets('ShouldShowTrackBusyMessageWhenTrackBusyCodeReturned', (tester) async {
    // arrange
    final fakeActions = _FakeVisitActions(errorToThrow: _visitStartError('TRACK_BUSY'));
    await tester.pumpWidget(
      buildTestable(
        const QrScanScreen(),
        overrides: [
          trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
          visitActionsProvider(trackId).overrideWith(() => fakeActions),
        ],
      ),
    );
    await tester.pump();

    // act
    fakePlatform.barcodesController.add(_capture('qr-token-1'));
    await tester.pump();
    await tester.pump();

    // assert
    expect(find.text('현재 진행중인 조가 있습니다'), findsOneWidget);
  });

  testWidgets('ShouldShowGroupAtCornerMessageWhenGroupAtCornerCodeReturned', (tester) async {
    // arrange
    final fakeActions = _FakeVisitActions(errorToThrow: _visitStartError('GROUP_AT_CORNER'));
    await tester.pumpWidget(
      buildTestable(
        const QrScanScreen(),
        overrides: [
          trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
          visitActionsProvider(trackId).overrideWith(() => fakeActions),
        ],
      ),
    );
    await tester.pump();

    // act
    fakePlatform.barcodesController.add(_capture('qr-token-1'));
    await tester.pump();
    await tester.pump();

    // assert
    expect(find.text('이 조는 현재 다른 코너에서 진행 중입니다'), findsOneWidget);
  });

  testWidgets('ShouldDisposeControllerExactlyOnceWhenScreenRemoved', (tester) async {
    // arrange
    final fakeActions = _FakeVisitActions();
    await tester.pumpWidget(
      buildTestable(
        const QrScanScreen(),
        overrides: [
          trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
          visitActionsProvider(trackId).overrideWith(() => fakeActions),
        ],
      ),
    );
    await tester.pump();

    // act: 화면을 트리에서 제거한다.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    // assert
    expect(fakePlatform.disposeCallCount, 1);
  });
}

/// TrackSession fake — 복원(_restore) 없이 곧바로 원하는 상태로 시작한다.
class _FakeTrackSession extends TrackSession {
  _FakeTrackSession(this._state);

  final TrackSessionState _state;

  @override
  TrackSessionState build() => _state;
}
