// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'admin_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminResponseRoleEnum _$adminResponseRoleEnum_SYSTEM_ADMIN =
    const AdminResponseRoleEnum._('SYSTEM_ADMIN');
const AdminResponseRoleEnum _$adminResponseRoleEnum_CORNER_OPERATOR =
    const AdminResponseRoleEnum._('CORNER_OPERATOR');

AdminResponseRoleEnum _$adminResponseRoleEnumValueOf(String name) {
  switch (name) {
    case 'SYSTEM_ADMIN':
      return _$adminResponseRoleEnum_SYSTEM_ADMIN;
    case 'CORNER_OPERATOR':
      return _$adminResponseRoleEnum_CORNER_OPERATOR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminResponseRoleEnum> _$adminResponseRoleEnumValues =
    BuiltSet<AdminResponseRoleEnum>(const <AdminResponseRoleEnum>[
  _$adminResponseRoleEnum_SYSTEM_ADMIN,
  _$adminResponseRoleEnum_CORNER_OPERATOR,
]);

Serializer<AdminResponseRoleEnum> _$adminResponseRoleEnumSerializer =
    _$AdminResponseRoleEnumSerializer();

class _$AdminResponseRoleEnumSerializer
    implements PrimitiveSerializer<AdminResponseRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SYSTEM_ADMIN': 'SYSTEM_ADMIN',
    'CORNER_OPERATOR': 'CORNER_OPERATOR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SYSTEM_ADMIN': 'SYSTEM_ADMIN',
    'CORNER_OPERATOR': 'CORNER_OPERATOR',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminResponseRoleEnum];
  @override
  final String wireName = 'AdminResponseRoleEnum';

  @override
  Object serialize(Serializers serializers, AdminResponseRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminResponseRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminResponseRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminResponse extends AdminResponse {
  @override
  final String? id;
  @override
  final AdminResponseRoleEnum? role;
  @override
  final String? username;

  factory _$AdminResponse([void Function(AdminResponseBuilder)? updates]) =>
      (AdminResponseBuilder()..update(updates))._build();

  _$AdminResponse._({this.id, this.role, this.username}) : super._();
  @override
  AdminResponse rebuild(void Function(AdminResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminResponseBuilder toBuilder() => AdminResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminResponse &&
        id == other.id &&
        role == other.role &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminResponse')
          ..add('id', id)
          ..add('role', role)
          ..add('username', username))
        .toString();
  }
}

class AdminResponseBuilder
    implements Builder<AdminResponse, AdminResponseBuilder> {
  _$AdminResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdminResponseRoleEnum? _role;
  AdminResponseRoleEnum? get role => _$this._role;
  set role(AdminResponseRoleEnum? role) => _$this._role = role;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  AdminResponseBuilder() {
    AdminResponse._defaults(this);
  }

  AdminResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _role = $v.role;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminResponse other) {
    _$v = other as _$AdminResponse;
  }

  @override
  void update(void Function(AdminResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminResponse build() => _build();

  _$AdminResponse _build() {
    final _$result = _$v ??
        _$AdminResponse._(
          id: id,
          role: role,
          username: username,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
