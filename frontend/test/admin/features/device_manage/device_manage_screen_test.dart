import 'package:cornermon/admin/features/device_manage/device_manage_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

final _campWithCode = CampResponse(
  (b) => b
    ..id = 'camp-1'
    ..name = '2026 여름 코너학습'
    ..registrationCode = '7ZQK3M2X',
);

class _FixedSelectedCampId extends SelectedCampId {
  @override
  CampId? build() => CampId('camp-1');
}

class _FixedSelectedCampSnapshot extends SelectedCampSnapshot {
  @override
  CampResponse? build() => _campWithCode;
}

List<Override> get _selectedCampOverrides => [
  selectedCampIdProvider.overrideWith(_FixedSelectedCampId.new),
  selectedCampSnapshotProvider.overrideWith(_FixedSelectedCampSnapshot.new),
];

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

final _campId = CampId('camp-1');

Future<void> _pump(
  WidgetTester tester,
  List<DeviceRegistrationResponse> items, {
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ..._selectedCampOverrides,
        deviceRegistrationListProvider(
          _campId,
        ).overrideWith((ref) async => items),
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
            _campId,
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

    testWidgets(
      'ShouldShowTopBannerWhenApproveFailsWithConnectionLoss',
      (tester) async {
        // arrange: 규칙 — 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)은 상단 배너.
        await _pump(
          tester,
          [_reg('1', DeviceRegistrationResponseStatusEnum.PENDING)],
          extraOverrides: [
            approveDeviceRegistrationProvider(
              _campId,
              DeviceRegistrationId('1'),
            ).overrideWith(
              (ref) async => throw DioException(
                requestOptions: RequestOptions(path: '/x'),
                type: DioExceptionType.connectionTimeout,
              ),
            ),
          ],
        );

        // act
        await tester.tap(find.text('승인'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('연결이 끊겼습니다 · 최근 상태를 보여주고 있어요'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'ShouldShowSnackBarWhenApproveFailsWithApiError',
      (tester) async {
        // arrange: 규칙 — API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar.
        await _pump(
          tester,
          [_reg('1', DeviceRegistrationResponseStatusEnum.PENDING)],
          extraOverrides: [
            approveDeviceRegistrationProvider(
              _campId,
              DeviceRegistrationId('1'),
            ).overrideWith(
              (ref) async => throw DioException(
                requestOptions: RequestOptions(path: '/x'),
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: RequestOptions(path: '/x'),
                  statusCode: 409,
                ),
              ),
            ),
          ],
        );

        // act
        await tester.tap(find.text('승인'));
        await tester.pumpAndSettle();

        // assert
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('연결이 끊겼습니다 · 최근 상태를 보여주고 있어요'), findsNothing);
      },
    );

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
            _campId,
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

    testWidgets('ShouldShowRegistrationCodeWhenCampIsSelected', (
      tester,
    ) async {
      // arrange / act
      await _pump(tester, const []);

      // assert
      expect(find.text('7ZQK3M2X'), findsOneWidget);
    });

    testWidgets('ShouldCopyRegistrationCodeToClipboardWhenTapped', (
      tester,
    ) async {
      // arrange
      final copiedCalls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedCalls.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await _pump(tester, const []);

      // act
      await tester.tap(find.text('7ZQK3M2X'));
      await tester.pumpAndSettle();

      // assert
      expect(copiedCalls, ['7ZQK3M2X']);
    });
  });
}
