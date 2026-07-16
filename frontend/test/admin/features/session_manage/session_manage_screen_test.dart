import 'package:cornermon/admin/features/session_manage/session_manage_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/not_implemented_exception.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

Future<void> _pump(
  WidgetTester tester, {
  required CampId campId,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
        ...extraOverrides,
      ],
      child: const MaterialApp(home: SessionManageScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final campId = CampId('camp-1');

  group('SessionManageScreen', () {
    testWidgets(
      'ShouldShowNotImplementedMessageWhenLockedDevicesReturns501',
      (tester) async {
        // arrange / act
        await _pump(
          tester,
          campId: campId,
          extraOverrides: [
            lockedDeviceListProvider(campId).overrideWith(
              (ref) async => throw const NotImplementedException('locked-devices'),
            ),
            activeSessionListProvider(campId).overrideWith((ref) async => []),
            trackListProvider(campId).overrideWith((ref) async => []),
            adminSessionListProvider.overrideWith((ref) async => []),
          ],
        );

        // assert
        expect(
          find.text('기기 잠금 조회는 백엔드 배포 후 제공됩니다(Issue #70)'),
          findsOneWidget,
        );
      },
    );

    testWidgets('ShouldReleaseLockoutWhenManualDeviceIdSubmitted', (
      tester,
    ) async {
      // arrange
      String? releasedDeviceId;
      await _pump(
        tester,
        campId: campId,
        extraOverrides: [
          lockedDeviceListProvider(campId).overrideWith((ref) async => []),
          activeSessionListProvider(campId).overrideWith((ref) async => []),
          trackListProvider(campId).overrideWith((ref) async => []),
          adminSessionListProvider.overrideWith((ref) async => []),
          releaseTrackLockoutProvider('device-99').overrideWith((ref) async {
            releasedDeviceId = 'device-99';
          }),
        ],
      );

      // act
      await tester.enterText(find.widgetWithText(TextField, '기기 ID'), 'device-99');
      await tester.tap(find.text('해제 실행'));
      await tester.pumpAndSettle();

      // assert
      expect(releasedDeviceId, 'device-99');
    });

    testWidgets('ShouldForceLogoutWhenManualTrackIdSubmitted', (tester) async {
      // arrange
      TrackId? loggedOutTrackId;
      await _pump(
        tester,
        campId: campId,
        extraOverrides: [
          lockedDeviceListProvider(campId).overrideWith((ref) async => []),
          activeSessionListProvider(campId).overrideWith((ref) async => []),
          trackListProvider(campId).overrideWith((ref) async => []),
          adminSessionListProvider.overrideWith((ref) async => []),
          forceLogoutTrackProvider(TrackId('track-7')).overrideWith((
            ref,
          ) async {
            loggedOutTrackId = TrackId('track-7');
          }),
        ],
      );

      // act
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '트랙 ID'), 'track-7');
      await tester.tap(find.text('강제 로그아웃').last);
      await tester.pumpAndSettle();

      // assert
      expect(loggedOutTrackId?.value, 'track-7');
    });

    testWidgets(
      'ShouldRequireConfirmationBeforeRevokingAdminSession',
      (tester) async {
        // arrange
        var revokeCalls = 0;
        await _pump(
          tester,
          campId: campId,
          extraOverrides: [
            lockedDeviceListProvider(campId).overrideWith((ref) async => []),
            activeSessionListProvider(campId).overrideWith((ref) async => []),
            trackListProvider(campId).overrideWith((ref) async => []),
            adminSessionListProvider.overrideWith(
              (ref) async => [
                AdminSessionResponse(
                  (b) => b
                    ..id = 'sess-1'
                    ..adminId = 'admin-1'
                    ..deviceInfo = 'iPad #1'
                    ..createdAt = DateTime(2026, 1, 1)
                    ..lastUsedAt = DateTime(2026, 1, 2),
                ),
              ],
            ),
            revokeAdminSessionProvider('sess-1').overrideWith((ref) async {
              revokeCalls++;
            }),
          ],
        );

        // act: tap then cancel
        await tester.drag(find.byType(ListView), const Offset(0, -800));
        await tester.pumpAndSettle();
        await tester.tap(find.text('세션 종료'));
        await tester.pumpAndSettle();
        expect(find.text('현재 세션을 종료하면 즉시 로그아웃됩니다'), findsOneWidget);
        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();

        // assert
        expect(revokeCalls, 0);
      },
    );
  });
}
