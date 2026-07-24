import 'package:cornermon/admin/features/admin_management/admin_management_screen.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

AdminResponse _admin(String id, String username, AdminResponseRoleEnum role) =>
    AdminResponse(
      (b) => b
        ..id = id
        ..username = username
        ..role = role,
    );

class _FakeAdminSession extends AdminSession {
  _FakeAdminSession(this._initial);
  final AdminSessionState _initial;
  bool invalidateCalled = false;

  @override
  AdminSessionState build() => _initial;

  @override
  Future<void> invalidate() async {
    invalidateCalled = true;
    state = const AdminSessionUnauthenticated();
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required List<Override> overrides,
  GoRouter? router,
}) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  final usedRouter =
      router ??
      GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const AdminManagementScreen()),
        ],
      );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: usedRouter),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AdminManagementScreen', () {
    testWidgets(
      'ShouldShowAdminListAndHideDeleteButtonForSelfWhenActorIsSystemAdmin',
      (tester) async {
        // arrange
        final me = _admin('sys-1', 'system', AdminResponseRoleEnum.SYSTEM_ADMIN);
        final operator = _admin(
          'op-1',
          'operator',
          AdminResponseRoleEnum.CORNER_OPERATOR,
        );

        // act
        await _pump(
          tester,
          overrides: [
            currentAdminProvider.overrideWith((ref) async => me),
            adminListProvider.overrideWith((ref) async => [me, operator]),
          ],
        );

        // assert
        expect(find.text('전체 관리자'), findsOneWidget);
        expect(find.text('system'), findsOneWidget);
        expect(find.text('operator'), findsOneWidget);
        expect(find.text('나'), findsOneWidget);
        expect(find.text('삭제'), findsOneWidget); // operator 행에만 노출
        expect(find.text('회원 탈퇴'), findsNothing); // SYSTEM_ADMIN은 본인 탈퇴 불가
      },
    );

    testWidgets('ShouldCreateAdminWhenDialogSubmitted', (tester) async {
      // arrange
      final me = _admin('sys-1', 'system', AdminResponseRoleEnum.SYSTEM_ADMIN);
      String? createdUsername;
      String? createdPassword;

      // act
      await _pump(
        tester,
        overrides: [
          currentAdminProvider.overrideWith((ref) async => me),
          adminListProvider.overrideWith((ref) async => [me]),
          createAdminProvider(
            'newop',
            'password1',
          ).overrideWith((ref) async {
            createdUsername = 'newop';
            createdPassword = 'password1';
            return _admin('op-2', 'newop', AdminResponseRoleEnum.CORNER_OPERATOR);
          }),
        ],
      );
      await tester.tap(find.text('운영 관리자 추가'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, '아이디'), 'newop');
      await tester.enterText(
        find.widgetWithText(TextField, '초기 비밀번호'),
        'password1',
      );
      await tester.pump();
      await tester.tap(find.text('추가'));
      await tester.pumpAndSettle();

      // assert
      expect(createdUsername, 'newop');
      expect(createdPassword, 'password1');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('ShouldDeleteAdminAfterConfirmation', (tester) async {
      // arrange
      final me = _admin('sys-1', 'system', AdminResponseRoleEnum.SYSTEM_ADMIN);
      final operator = _admin(
        'op-1',
        'operator',
        AdminResponseRoleEnum.CORNER_OPERATOR,
      );
      var deleteCalls = 0;

      // act
      await _pump(
        tester,
        overrides: [
          currentAdminProvider.overrideWith((ref) async => me),
          adminListProvider.overrideWith((ref) async => [me, operator]),
          deleteAdminAccountProvider('op-1').overrideWith((ref) async {
            deleteCalls++;
          }),
        ],
      );
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();
      expect(find.text('operator를 삭제하시겠습니까?'), findsOneWidget);
      await tester.tap(find.text('진행'));
      await tester.pumpAndSettle();

      // assert
      expect(deleteCalls, 1);
    });

    testWidgets(
      'ShouldNotDeleteAdminWhenConfirmationCancelled',
      (tester) async {
        // arrange
        final me = _admin('sys-1', 'system', AdminResponseRoleEnum.SYSTEM_ADMIN);
        final operator = _admin(
          'op-1',
          'operator',
          AdminResponseRoleEnum.CORNER_OPERATOR,
        );
        var deleteCalls = 0;

        // act
        await _pump(
          tester,
          overrides: [
            currentAdminProvider.overrideWith((ref) async => me),
            adminListProvider.overrideWith((ref) async => [me, operator]),
            deleteAdminAccountProvider('op-1').overrideWith((ref) async {
              deleteCalls++;
            }),
          ],
        );
        await tester.tap(find.text('삭제'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();

        // assert
        expect(deleteCalls, 0);
      },
    );

    testWidgets(
      'ShouldHideAdminListSectionWhenActorIsCornerOperator',
      (tester) async {
        // arrange
        final me = _admin(
          'op-1',
          'operator',
          AdminResponseRoleEnum.CORNER_OPERATOR,
        );

        // act
        await _pump(
          tester,
          overrides: [
            currentAdminProvider.overrideWith((ref) async => me),
          ],
        );

        // assert
        expect(find.text('전체 관리자'), findsNothing);
        expect(find.textContaining('operator'), findsOneWidget);
        expect(find.text('회원 탈퇴'), findsOneWidget);
      },
    );

    testWidgets('ShouldChangeOwnPasswordWhenSubmitted', (tester) async {
      // arrange
      final me = _admin(
        'op-1',
        'operator',
        AdminResponseRoleEnum.CORNER_OPERATOR,
      );
      String? changedPassword;

      // act
      await _pump(
        tester,
        overrides: [
          currentAdminProvider.overrideWith((ref) async => me),
          changeAdminPasswordProvider(
            'op-1',
            'new-password',
          ).overrideWith((ref) async {
            changedPassword = 'new-password';
          }),
        ],
      );
      await tester.enterText(
        find.widgetWithText(TextField, '새 비밀번호'),
        'new-password',
      );
      await tester.pump();
      await tester.tap(find.text('비밀번호 변경'));
      await tester.pumpAndSettle();

      // assert
      expect(changedPassword, 'new-password');
      expect(find.text('비밀번호가 변경되었습니다.'), findsOneWidget);
    });

    testWidgets(
      'ShouldWithdrawAndInvalidateSessionWhenConfirmed',
      (tester) async {
        // arrange
        final me = _admin(
          'op-1',
          'operator',
          AdminResponseRoleEnum.CORNER_OPERATOR,
        );
        var deleteCalls = 0;
        final fakeSession = _FakeAdminSession(
          const AdminSessionAuthenticated(accessToken: 'token', adminId: 'op-1'),
        );
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const AdminManagementScreen(),
            ),
            GoRoute(path: '/login', builder: (_, _) => const Text('login-screen')),
          ],
        );

        // act
        await _pump(
          tester,
          router: router,
          overrides: [
            currentAdminProvider.overrideWith((ref) async => me),
            deleteAdminAccountProvider('op-1').overrideWith((ref) async {
              deleteCalls++;
            }),
            adminSessionProvider.overrideWith(() => fakeSession),
          ],
        );
        await tester.tap(find.text('회원 탈퇴'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('진행'));
        await tester.pumpAndSettle();

        // assert
        expect(deleteCalls, 1);
        expect(fakeSession.invalidateCalled, isTrue);
        expect(find.text('login-screen'), findsOneWidget);
      },
    );
  });
}
