import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';

const _accessTokenKey = 'admin_access_token';
const _adminIdKey = 'admin_id';

sealed class AdminSessionState {
  const AdminSessionState();

  String? get accessTokenOrNull => null;
}

class AdminSessionUnauthenticated extends AdminSessionState {
  const AdminSessionUnauthenticated();
}

class AdminSessionAuthenticated extends AdminSessionState {
  const AdminSessionAuthenticated({
    required this.accessToken,
    required this.adminId,
  });

  final String accessToken;
  final String adminId;

  @override
  String get accessTokenOrNull => accessToken;
}

final adminSessionProvider = NotifierProvider<AdminSession, AdminSessionState>(
  AdminSession.new,
);

class AdminSession extends Notifier<AdminSessionState> {
  @override
  AdminSessionState build() {
    unawaited(_restore());
    return const AdminSessionUnauthenticated();
  }

  Future<void> _restore() async {
    final store = ref.read(secureTokenStoreProvider);
    final accessToken = await store.read(_accessTokenKey);
    if (accessToken == null) return;
    final adminId = await store.read(_adminIdKey) ?? '';
    state = AdminSessionAuthenticated(
      accessToken: accessToken,
      adminId: adminId,
    );
  }

  Future<void> login(String loginId, String password) async {
    final provider = adminLoginProvider(loginId, password);
    final sub = ref.listen(provider, (_, _) {});
    final response = await ref.read(provider.future).whenComplete(sub.close);
    final accessToken = response.accessToken;
    if (accessToken == null) {
      throw Exception('관리자 로그인 응답에 토큰이 없습니다.');
    }

    final store = ref.read(secureTokenStoreProvider);
    await store.write(_accessTokenKey, accessToken);
    await store.write(_adminIdKey, loginId);
    state = AdminSessionAuthenticated(
      accessToken: accessToken,
      adminId: loginId,
    );
    ref.invalidate(campListProvider);
  }

  /// 슬라이딩 세션: 서버가 인증된 요청마다 만료를 자동 연장하므로 별도 refresh 호출이 없다.
  /// 401을 받았다는 것은 세션이 이미 만료/무효화됐다는 뜻이므로 로컬 상태만 정리한다.
  Future<void> invalidate() => _becomeUnauthenticated();

  Future<void> logout() async {
    final sub = ref.listen(adminLogoutProvider, (_, _) {});
    try {
      await ref.read(adminLogoutProvider.future);
    } finally {
      sub.close();
      await _becomeUnauthenticated();
    }
  }

  Future<void> _becomeUnauthenticated() async {
    final store = ref.read(secureTokenStoreProvider);
    await store.delete(_accessTokenKey);
    await store.delete(_adminIdKey);
    state = const AdminSessionUnauthenticated();
  }
}
