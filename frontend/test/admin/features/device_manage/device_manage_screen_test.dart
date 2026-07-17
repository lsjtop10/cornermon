import 'package:cornermon/admin/features/device_manage/device_manage_screen.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

DeviceRegistrationResponse _reg(
  String id,
  DeviceRegistrationResponseStatusEnum status,
) => DeviceRegistrationResponse(
  (b) => b
    ..id = id
    ..deviceName = 'device-$id'
    ..status = status
    ..createdAt = DateTime(2026, 1, 1),
);

Future<void> _pump(
  WidgetTester tester,
  List<DeviceRegistrationResponse> items, {
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deviceRegistrationListProvider.overrideWith((ref) async => items),
        ...extraOverrides,
      ],
      child: const MaterialApp(home: DeviceManageScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DeviceManageScreen', () {
    testWidgets('ShouldShowEmptyStateWhenNoPendingRegistrations', (
      tester,
    ) async {
      // arrange / act
      await _pump(tester, const []);

      // assert
      expect(find.text('대기 중인 등록 요청이 없습니다'), findsOneWidget);
    });

    testWidgets('ShouldShowPendingCountBadgeInTabLabel', (tester) async {
      // arrange / act
      await _pump(tester, [
        _reg('1', DeviceRegistrationResponseStatusEnum.PENDING),
        _reg('2', DeviceRegistrationResponseStatusEnum.PENDING),
      ]);

      // assert
      expect(find.text('대기중'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('ShouldApproveAndRefreshListWhenApproveButtonTapped', (
      tester,
    ) async {
      // arrange
      var approveCalls = 0;
      await _pump(
        tester,
        [_reg('1', DeviceRegistrationResponseStatusEnum.PENDING)],
        extraOverrides: [
          approveDeviceRegistrationProvider(
            DeviceRegistrationId('1'),
          ).overrideWith((ref) async {
            approveCalls++;
            return _reg('1', DeviceRegistrationResponseStatusEnum.APPROVED);
          }),
        ],
      );

      // act
      await tester.tap(find.text('승인'));
      await tester.pumpAndSettle();

      // assert
      expect(approveCalls, 1);
    });

    testWidgets('ShouldRequireConfirmationBeforeRevokingApprovedDevice', (
      tester,
    ) async {
      // arrange
      var revokeCalls = 0;
      await _pump(
        tester,
        [_reg('1', DeviceRegistrationResponseStatusEnum.APPROVED)],
        extraOverrides: [
          revokeDeviceRegistrationProvider(
            DeviceRegistrationId('1'),
          ).overrideWith((ref) async {
            revokeCalls++;
            return _reg('1', DeviceRegistrationResponseStatusEnum.REVOKED);
          }),
        ],
      );
      await tester.tap(find.text('승인됨'));
      await tester.pumpAndSettle();

      // act: tap revoke, then cancel — must not call API
      await tester.tap(find.text('회수'));
      await tester.pumpAndSettle();
      expect(find.text('기기를 회수하시겠습니까?'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // assert
      expect(revokeCalls, 0);
    });

    testWidgets('ShouldShowNoActionButtonsForHistoryTab', (tester) async {
      // arrange
      await _pump(tester, [
        _reg('1', DeviceRegistrationResponseStatusEnum.REJECTED),
      ]);

      // act
      await tester.tap(find.text('거절·회수 이력'));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('거절됨'), findsOneWidget);
      expect(find.text('승인'), findsNothing);
      expect(find.text('회수'), findsNothing);
    });
  });
}
