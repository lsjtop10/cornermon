// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_start_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VisitStartRequestMethodEnum _$visitStartRequestMethodEnum_MANUAL =
    const VisitStartRequestMethodEnum._('MANUAL');

VisitStartRequestMethodEnum _$visitStartRequestMethodEnumValueOf(String name) {
  switch (name) {
    case 'MANUAL':
      return _$visitStartRequestMethodEnum_MANUAL;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VisitStartRequestMethodEnum>
    _$visitStartRequestMethodEnumValues =
    BuiltSet<VisitStartRequestMethodEnum>(const <VisitStartRequestMethodEnum>[
  _$visitStartRequestMethodEnum_MANUAL,
]);

Serializer<VisitStartRequestMethodEnum>
    _$visitStartRequestMethodEnumSerializer =
    _$VisitStartRequestMethodEnumSerializer();

class _$VisitStartRequestMethodEnumSerializer
    implements PrimitiveSerializer<VisitStartRequestMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MANUAL': 'MANUAL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MANUAL': 'MANUAL',
  };

  @override
  final Iterable<Type> types = const <Type>[VisitStartRequestMethodEnum];
  @override
  final String wireName = 'VisitStartRequestMethodEnum';

  @override
  Object serialize(Serializers serializers, VisitStartRequestMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VisitStartRequestMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VisitStartRequestMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VisitStartRequest extends VisitStartRequest {
  @override
  final String? groupId;
  @override
  final VisitStartRequestMethodEnum? method;
  @override
  final String? qrToken;

  factory _$VisitStartRequest(
          [void Function(VisitStartRequestBuilder)? updates]) =>
      (VisitStartRequestBuilder()..update(updates))._build();

  _$VisitStartRequest._({this.groupId, this.method, this.qrToken}) : super._();
  @override
  VisitStartRequest rebuild(void Function(VisitStartRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VisitStartRequestBuilder toBuilder() =>
      VisitStartRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VisitStartRequest &&
        groupId == other.groupId &&
        method == other.method &&
        qrToken == other.qrToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, qrToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VisitStartRequest')
          ..add('groupId', groupId)
          ..add('method', method)
          ..add('qrToken', qrToken))
        .toString();
  }
}

class VisitStartRequestBuilder
    implements Builder<VisitStartRequest, VisitStartRequestBuilder> {
  _$VisitStartRequest? _$v;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  VisitStartRequestMethodEnum? _method;
  VisitStartRequestMethodEnum? get method => _$this._method;
  set method(VisitStartRequestMethodEnum? method) => _$this._method = method;

  String? _qrToken;
  String? get qrToken => _$this._qrToken;
  set qrToken(String? qrToken) => _$this._qrToken = qrToken;

  VisitStartRequestBuilder() {
    VisitStartRequest._defaults(this);
  }

  VisitStartRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupId = $v.groupId;
      _method = $v.method;
      _qrToken = $v.qrToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VisitStartRequest other) {
    _$v = other as _$VisitStartRequest;
  }

  @override
  void update(void Function(VisitStartRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VisitStartRequest build() => _build();

  _$VisitStartRequest _build() {
    final _$result = _$v ??
        _$VisitStartRequest._(
          groupId: groupId,
          method: method,
          qrToken: qrToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
