// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'create_admin_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateAdminRequestRoleEnum _$createAdminRequestRoleEnum_CORNER_OPERATOR =
    const CreateAdminRequestRoleEnum._('CORNER_OPERATOR');

CreateAdminRequestRoleEnum _$createAdminRequestRoleEnumValueOf(String name) {
  switch (name) {
    case 'CORNER_OPERATOR':
      return _$createAdminRequestRoleEnum_CORNER_OPERATOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateAdminRequestRoleEnum> _$createAdminRequestRoleEnumValues =
    BuiltSet<CreateAdminRequestRoleEnum>(const <CreateAdminRequestRoleEnum>[
  _$createAdminRequestRoleEnum_CORNER_OPERATOR,
]);

Serializer<CreateAdminRequestRoleEnum> _$createAdminRequestRoleEnumSerializer =
    _$CreateAdminRequestRoleEnumSerializer();

class _$CreateAdminRequestRoleEnumSerializer
    implements PrimitiveSerializer<CreateAdminRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'CORNER_OPERATOR': 'CORNER_OPERATOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'CORNER_OPERATOR': 'CORNER_OPERATOR',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateAdminRequestRoleEnum];
  @override
  final String wireName = 'CreateAdminRequestRoleEnum';

  @override
  Object serialize(Serializers serializers, CreateAdminRequestRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateAdminRequestRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateAdminRequestRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateAdminRequest extends CreateAdminRequest {
  @override
  final String? password;
  @override
  final CreateAdminRequestRoleEnum? role;
  @override
  final String? username;

  factory _$CreateAdminRequest(
          [void Function(CreateAdminRequestBuilder)? updates]) =>
      (CreateAdminRequestBuilder()..update(updates))._build();

  _$CreateAdminRequest._({this.password, this.role, this.username}) : super._();
  @override
  CreateAdminRequest rebuild(
          void Function(CreateAdminRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateAdminRequestBuilder toBuilder() =>
      CreateAdminRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateAdminRequest &&
        password == other.password &&
        role == other.role &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateAdminRequest')
          ..add('password', password)
          ..add('role', role)
          ..add('username', username))
        .toString();
  }
}

class CreateAdminRequestBuilder
    implements Builder<CreateAdminRequest, CreateAdminRequestBuilder> {
  _$CreateAdminRequest? _$v;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  CreateAdminRequestRoleEnum? _role;
  CreateAdminRequestRoleEnum? get role => _$this._role;
  set role(CreateAdminRequestRoleEnum? role) => _$this._role = role;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  CreateAdminRequestBuilder() {
    CreateAdminRequest._defaults(this);
  }

  CreateAdminRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _password = $v.password;
      _role = $v.role;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateAdminRequest other) {
    _$v = other as _$CreateAdminRequest;
  }

  @override
  void update(void Function(CreateAdminRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateAdminRequest build() => _build();

  _$CreateAdminRequest _build() {
    final _$result = _$v ??
        _$CreateAdminRequest._(
          password: password,
          role: role,
          username: username,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
