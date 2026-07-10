// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_track_login_post200_response_corner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthTrackLoginPost200ResponseCorner
    extends AuthTrackLoginPost200ResponseCorner {
  @override
  final String? id;
  @override
  final String? name;

  factory _$AuthTrackLoginPost200ResponseCorner([
    void Function(AuthTrackLoginPost200ResponseCornerBuilder)? updates,
  ]) =>
      (AuthTrackLoginPost200ResponseCornerBuilder()..update(updates))._build();

  _$AuthTrackLoginPost200ResponseCorner._({this.id, this.name}) : super._();
  @override
  AuthTrackLoginPost200ResponseCorner rebuild(
    void Function(AuthTrackLoginPost200ResponseCornerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AuthTrackLoginPost200ResponseCornerBuilder toBuilder() =>
      AuthTrackLoginPost200ResponseCornerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthTrackLoginPost200ResponseCorner &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthTrackLoginPost200ResponseCorner')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class AuthTrackLoginPost200ResponseCornerBuilder
    implements
        Builder<
          AuthTrackLoginPost200ResponseCorner,
          AuthTrackLoginPost200ResponseCornerBuilder
        > {
  _$AuthTrackLoginPost200ResponseCorner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AuthTrackLoginPost200ResponseCornerBuilder() {
    AuthTrackLoginPost200ResponseCorner._defaults(this);
  }

  AuthTrackLoginPost200ResponseCornerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthTrackLoginPost200ResponseCorner other) {
    _$v = other as _$AuthTrackLoginPost200ResponseCorner;
  }

  @override
  void update(
    void Function(AuthTrackLoginPost200ResponseCornerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AuthTrackLoginPost200ResponseCorner build() => _build();

  _$AuthTrackLoginPost200ResponseCorner _build() {
    final _$result =
        _$v ?? _$AuthTrackLoginPost200ResponseCorner._(id: id, name: name);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
