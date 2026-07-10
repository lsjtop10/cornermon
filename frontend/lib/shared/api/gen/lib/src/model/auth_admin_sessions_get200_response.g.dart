// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_admin_sessions_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthAdminSessionsGet200Response
    extends AuthAdminSessionsGet200Response {
  @override
  final BuiltList<AdminSession>? sessions;

  factory _$AuthAdminSessionsGet200Response([
    void Function(AuthAdminSessionsGet200ResponseBuilder)? updates,
  ]) => (AuthAdminSessionsGet200ResponseBuilder()..update(updates))._build();

  _$AuthAdminSessionsGet200Response._({this.sessions}) : super._();
  @override
  AuthAdminSessionsGet200Response rebuild(
    void Function(AuthAdminSessionsGet200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthAdminSessionsGet200ResponseBuilder toBuilder() =>
      AuthAdminSessionsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthAdminSessionsGet200Response &&
        sessions == other.sessions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AuthAdminSessionsGet200Response',
    )..add('sessions', sessions)).toString();
  }
}

class AuthAdminSessionsGet200ResponseBuilder
    implements
        Builder<
          AuthAdminSessionsGet200Response,
          AuthAdminSessionsGet200ResponseBuilder
        > {
  _$AuthAdminSessionsGet200Response? _$v;

  ListBuilder<AdminSession>? _sessions;
  ListBuilder<AdminSession> get sessions =>
      _$this._sessions ??= ListBuilder<AdminSession>();
  set sessions(ListBuilder<AdminSession>? sessions) =>
      _$this._sessions = sessions;

  AuthAdminSessionsGet200ResponseBuilder() {
    AuthAdminSessionsGet200Response._defaults(this);
  }

  AuthAdminSessionsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessions = $v.sessions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthAdminSessionsGet200Response other) {
    _$v = other as _$AuthAdminSessionsGet200Response;
  }

  @override
  void update(void Function(AuthAdminSessionsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthAdminSessionsGet200Response build() => _build();

  _$AuthAdminSessionsGet200Response _build() {
    _$AuthAdminSessionsGet200Response _$result;
    try {
      _$result =
          _$v ??
          _$AuthAdminSessionsGet200Response._(sessions: _sessions?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sessions';
        _sessions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AuthAdminSessionsGet200Response',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
