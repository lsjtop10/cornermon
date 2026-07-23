import 'package:cornermon/facilitator/features/device_pending/device_pending_screen.dart';
import 'package:cornermon/facilitator/features/main_track/main_track_screen.dart';
import 'package:cornermon/facilitator/features/pin_login/pin_login_screen.dart';
import 'package:cornermon/facilitator/features/qr_scan/qr_scan_screen.dart';
import 'package:cornermon/facilitator/features/track_confirm/track_confirm_screen.dart';
import 'package:cornermon/facilitator/router/facilitator_router.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/facilitator/session/facilitator_broadcast_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/api/sse/track_event_stream.dart';
import 'package:cornermon/shared/api/sse/sse_event_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// mobile_scanner의 실제 플랫폼 채널을 회피하기 위한 최소 가짜 구현
/// (QrScanScreen이 포함된 라우트로 이동하는 시나리오에서만 필요).
class _FakeMobileScannerPlatform extends MobileScannerPlatform {
  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();

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
  Future<void> dispose() async {}
}

/// DeviceTrust fake — 시큐어스토리지 접근 없이 고정 상태로 시작한다.
class _FakeDeviceTrust extends DeviceTrust {
  _FakeDeviceTrust(this._status);

  final DeviceTrustStatus _status;

  @override
  Future<DeviceTrustStatus> build() async => _status;
}

/// TrackSession fake — 복원(_restore) 없이 곧바로 원하는 상태로 시작하고,
/// 이후 강제종료 등 상태 전이를 테스트에서 시큐어스토리지 접근 없이 직접 트리거한다.
class _MutableTrackSession extends TrackSession {
  _MutableTrackSession(this._initial);

  final TrackSessionState _initial;

  @override
  TrackSessionState build() => _initial;

  void setState(TrackSessionState newState) => state = newState;
}

/// facilitatorRouterProvider를 구독해 실제 앱과 동일하게 GoRouter를 붙인다.
Widget _buildApp(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: Consumer(
        builder: (context, ref, _) =>
            MaterialApp.router(routerConfig: ref.watch(facilitatorRouterProvider)),
      ),
    );

void main() {
  final trackId = TrackId('track-1');

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

  testWidgets('ShouldStartAtDevicePendingOnBoot', (tester) async {
    // arrange & act: deviceTrust 기본값(none)으로 앱을 처음 부팅한다.
    await tester.pumpWidget(
      _buildApp([
        deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.none)),
        trackSessionProvider
            .overrideWith(() => _MutableTrackSession(const TrackSessionUnauthenticated())),
      ]),
    );
    await tester.pump();
    await tester.pump();

    // assert
    expect(find.byType(DevicePendingScreen), findsOneWidget);
  });

  testWidgets(
    'ShouldRedirectBackToDevicePendingWhenNavigatingToPinLoginWithDeviceTrustNone',
    (tester) async {
      // arrange
      await tester.pumpWidget(
        _buildApp([
          deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.none)),
          trackSessionProvider
              .overrideWith(() => _MutableTrackSession(const TrackSessionUnauthenticated())),
        ]),
      );
      await tester.pump();
      await tester.pump();

      // act: URL 직접 조작으로 /pin-login 진입을 시도한다.
      final context = tester.element(find.byType(DevicePendingScreen));
      GoRouter.of(context).go('/pin-login');
      await tester.pump();
      await tester.pump();

      // assert: deviceTrust == none이므로 되돌려진다.
      expect(find.byType(DevicePendingScreen), findsOneWidget);
      expect(find.byType(PinLoginScreen), findsNothing);
    },
  );

  testWidgets(
    'ShouldRedirectToDevicePendingWhenDeviceTrustIsPending',
    (tester) async {
      // arrange: deviceTrust == pending은 screen-spec-facilitator.md B0에 따라
      // APPROVED 감지 전까지 앱 사용 자체가 차단되어야 한다(none/rejected/revoked와 동일).
      await tester.pumpWidget(
        _buildApp([
          deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.pending)),
          trackSessionProvider
              .overrideWith(() => _MutableTrackSession(const TrackSessionUnauthenticated())),
        ]),
      );
      await tester.pump();
      await tester.pump();

      // assert: /pin-login으로 진입을 시도해도 /device-pending으로 되돌려진다.
      expect(find.byType(DevicePendingScreen), findsOneWidget);
      expect(find.byType(PinLoginScreen), findsNothing);
    },
  );

  testWidgets(
    'ShouldRedirectToConfirmWhenTrackSessionIsPendingConfirmationEvenWhenTargetingMain',
    (tester) async {
      // arrange
      final pendingState = TrackSessionPendingConfirmation(
        trackToken: 'pending-token',
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
      await tester.pumpWidget(
        _buildApp([
          deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.approved)),
          trackSessionProvider.overrideWith(() => _MutableTrackSession(pendingState)),
        ]),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(TrackConfirmScreen), findsOneWidget);

      // act: 뒤로가기 대신 /main으로 직접 이동을 시도한다(=뒤로가기로 건너뛰려는 시도의 대용).
      final context = tester.element(find.byType(TrackConfirmScreen));
      GoRouter.of(context).go('/main');
      await tester.pump();
      await tester.pump();

      // assert: PendingConfirmation 상태가 유지되는 한 여전히 /pin-login/confirm으로 되돌려진다.
      expect(find.byType(TrackConfirmScreen), findsOneWidget);
      expect(find.byType(MainTrackScreen), findsNothing);
    },
  );

  testWidgets(
    'ShouldRedirectToPinLoginImmediatelyWhenSessionForceTerminatedDeepInStack',
    (tester) async {
      // arrange: /main/scan까지 정상적으로 도달한 인증 상태로 시작한다.
      MobileScannerPlatform.instance = _FakeMobileScannerPlatform();
      final mutableSession = _MutableTrackSession(buildAuthenticatedState());

      await tester.pumpWidget(
        _buildApp([
          deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.approved)),
          trackSessionProvider.overrideWith(() => mutableSession),
          currentVisitProvider(trackId).overrideWith((ref) => null),
          trackCornerProvider(trackId).overrideWith(
            (ref) => Corner(
              (b) => b
                ..id = 'corner-1'
                ..name = '입장'
                ..targetMinutes = 10
                ..status = CornerOperationalStatus.IDLE,
            ),
          ),
          facilitatorBroadcastMessageListProvider.overrideWith((ref) => <Message>[]),
          trackEventsProvider(
            trackId,
          ).overrideWith((ref) => const Stream<SseEventReceipt>.empty()),
        ]),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(MainTrackScreen), findsOneWidget);

      final context = tester.element(find.byType(MainTrackScreen));
      GoRouter.of(context).go('/main/scan');
      await tester.pump();
      await tester.pump();
      expect(find.byType(QrScanScreen), findsOneWidget);

      // act: 트랙 삭제/강제로그아웃 등으로 세션이 즉시 종료된다(스택 깊이 2단계인 상태에서).
      mutableSession.setState(
        const TrackSessionUnauthenticated(
          lastTerminationReason: TrackSessionTerminationReason.forceLogout,
        ),
      );
      await tester.pumpAndSettle();

      // assert: 중간 화면을 하나씩 pop하지 않고 곧바로 /pin-login으로 전환된다.
      expect(find.byType(PinLoginScreen), findsOneWidget);
      expect(find.byType(QrScanScreen), findsNothing);
      expect(find.byType(MainTrackScreen), findsNothing);
    },
  );
}
