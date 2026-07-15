import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/auth/secure_token_store.dart';

const _refreshTokenKey = 'admin_refresh_token';
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
    required this.refreshToken,
    required this.adminId,
  });

  final String accessToken;
  final String refreshToken;
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
    final refreshToken = await store.read(_refreshTokenKey);
    if (refreshToken == null) return;
    await refreshSession(
      refreshToken: refreshToken,
      adminId: await store.read(_adminIdKey) ?? '',
    );
  }

  Future<void> login(String loginId, String password) async {
    final response = await ref.read(
      adminLoginProvider(loginId, password).future,
    );
    final accessToken = response.accessToken;
    final refreshToken = response.refreshToken;
    if (accessToken == null || refreshToken == null) {
      throw Exception('관리자 로그인 응답에 토큰이 없습니다.');
    }

    final store = ref.read(secureTokenStoreProvider);
    await store.write(_refreshTokenKey, refreshToken);
    await store.write(_adminIdKey, loginId);
    state = AdminSessionAuthenticated(
      accessToken: accessToken,
      refreshToken: refreshToken,
      adminId: loginId,
    );
  }

  Future<bool> refreshSession({String? refreshToken, String? adminId}) async {
    final current = state;
    final token =
        refreshToken ??
        (current is AdminSessionAuthenticated ? current.refreshToken : null);
    if (token == null) {
      await _becomeUnauthenticated();
      return false;
    }

    try {
      final response = await ref.read(adminRefreshProvider.future);
      final accessToken = response.accessToken;
      if (accessToken == null) throw Exception('관리자 토큰 갱신 응답이 비어 있습니다.');
      state = AdminSessionAuthenticated(
        accessToken: accessToken,
        refreshToken: token,
        adminId:
            adminId ??
            (current is AdminSessionAuthenticated ? current.adminId : ''),
      );
      return true;
    } catch (_) {
      await _becomeUnauthenticated();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(adminLogoutProvider.future);
    } finally {
      await _becomeUnauthenticated();
    }
  }

  Future<void> _becomeUnauthenticated() async {
    final store = ref.read(secureTokenStoreProvider);
    await store.delete(_refreshTokenKey);
    await store.delete(_adminIdKey);
    state = const AdminSessionUnauthenticated();
  }
}
