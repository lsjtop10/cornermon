import 'dart:async';

import 'package:cornermon/admin/features/login/login_error_provider.dart';
import 'package:cornermon/admin/features/login/login_screen.dart';
import 'package:cornermon/admin/session/admin_session_provider.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';
import 'package:cornermon/shared/config/active_api_environment_provider.dart';
import 'package:cornermon/shared/config/api_environment.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

class _MemoryTokenStore implements SecureTokenStore {
  final values = <String, String>{};
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

class _ThrowingAdminSession extends AdminSession {
  _ThrowingAdminSession(this.error);
  final Object error;
  @override
  AdminSessionState build() => const AdminSessionUnauthenticated();
  @override
  Future<void> login(String loginId, String password) => Future.error(error);
}

class _PendingAdminSession extends AdminSession {
  _PendingAdminSession(this.completer);
  final Completer<void> completer;
  @override
  AdminSessionState build() => const AdminSessionUnauthenticated();
  @override
  Future<void> login(String loginId, String password) => completer.future;
}

Widget _app(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(home: LoginScreen()),
);

void main() {
  test('stores a successful login as an authenticated admin session', () async {
    final store = _MemoryTokenStore();
    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWithValue(store),
        adminLoginProvider('admin', 'password').overrideWith(
          (ref) async => AdminLoginResponse(
            (builder) => builder..accessToken = 'access',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(adminSessionProvider.notifier)
        .login('admin', 'password');

    expect(
      container.read(adminSessionProvider),
      isA<AdminSessionAuthenticated>(),
    );
    expect(store.values['admin_access_token'], 'access');
  });

  test('maps 401 and other failures to distinct login UI errors', () async {
    final request = RequestOptions(path: '/auth/admin/login');
    final unauthorized = DioException(
      requestOptions: request,
      response: Response(statusCode: 401, requestOptions: request),
    );
    for (final expectation in <(Object, Type)>[
      (unauthorized, AdminLoginInvalidCredentials),
      (StateError('server'), AdminLoginServerError),
    ]) {
      final container = ProviderContainer(
        overrides: [
          adminSessionProvider.overrideWith(
            () => _ThrowingAdminSession(expectation.$1),
          ),
        ],
      );
      await expectLater(
        container.read(loginErrorProvider.notifier).submit('admin', 'password'),
        throwsA(anything),
      );
      expect(container.read(loginErrorProvider).runtimeType, expectation.$2);
      container.dispose();
    }
  });

  testWidgets(
    'renders an inline credentials error and disables the button while submitting',
    (tester) async {
      await tester.pumpWidget(
        _app([
          loginErrorProvider.overrideWithValue(
            const AdminLoginInvalidCredentials(),
          ),
        ]),
      );
      expect(find.text('ID 또는 비밀번호가 올바르지 않습니다'), findsOneWidget);

      final pending = Completer<void>();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        _app([
          adminSessionProvider.overrideWith(
            () => _PendingAdminSession(pending),
          ),
        ]),
      );
      await tester.enterText(find.byType(TextField).at(0), 'admin');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.pump();
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      pending.complete();
    },
  );

  testWidgets(
    'toggles the active API environment when the footer caption is long-pressed',
    (tester) async {
      // arrange — 새 UI 추가 없이 기존 하단 캡션 텍스트에 얹힌 히든 진입점을 검증한다.
      await tester.pumpWidget(_app([]));

      // act — 첫 롱프레스: 운영 → 데모.
      await tester.longPress(find.text('로그인 상태는 안전하게 유지됩니다.'));

      // assert — 상태 전환은 즉시 반영되고, 스낵바 문구는 진입 애니메이션이 끝난 뒤 보인다.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(LoginScreen)),
      );
      expect(container.read(activeApiEnvironmentProvider), ApiEnvironment.demo);
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('심사용 서버로 전환됨'), findsOneWidget);

      // act — 두 번째 롱프레스: 데모 → 운영으로 되돌아간다. 첫 스낵바의 자동 소멸 타이머는
      // (pumpAndSettle이 기다려주지 않는) 실제 Timer라서, 명시적으로 그 시간만큼 흘려보내야
      // 두 번째 스낵바가 큐에 밀리지 않고 바로 뜬다.
      await tester.pump(const Duration(seconds: 5));
      await tester.longPress(find.text('로그인 상태는 안전하게 유지됩니다.'));

      // assert — 상태 전환은 즉시 반영되고, 스낵바 문구는 진입 애니메이션이 끝난 뒤 보인다.
      expect(container.read(activeApiEnvironmentProvider), ApiEnvironment.production);
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.text('운영 서버로 전환됨'), findsOneWidget);
    },
  );
}
