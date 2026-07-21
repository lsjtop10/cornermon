// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'corner_progress_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CornerProgressResponseStatusEnum
    _$cornerProgressResponseStatusEnum_NOT_VISITED =
    const CornerProgressResponseStatusEnum._('NOT_VISITED');
const CornerProgressResponseStatusEnum
    _$cornerProgressResponseStatusEnum_IN_PROGRESS =
    const CornerProgressResponseStatusEnum._('IN_PROGRESS');
const CornerProgressResponseStatusEnum
    _$cornerProgressResponseStatusEnum_COMPLETED =
    const CornerProgressResponseStatusEnum._('COMPLETED');

CornerProgressResponseStatusEnum _$cornerProgressResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'NOT_VISITED':
      return _$cornerProgressResponseStatusEnum_NOT_VISITED;
    case 'IN_PROGRESS':
      return _$cornerProgressResponseStatusEnum_IN_PROGRESS;
    case 'COMPLETED':
      return _$cornerProgressResponseStatusEnum_COMPLETED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CornerProgressResponseStatusEnum>
    _$cornerProgressResponseStatusEnumValues = BuiltSet<
        CornerProgressResponseStatusEnum>(const <CornerProgressResponseStatusEnum>[
  _$cornerProgressResponseStatusEnum_NOT_VISITED,
  _$cornerProgressResponseStatusEnum_IN_PROGRESS,
  _$cornerProgressResponseStatusEnum_COMPLETED,
]);

Serializer<CornerProgressResponseStatusEnum>
    _$cornerProgressResponseStatusEnumSerializer =
    _$CornerProgressResponseStatusEnumSerializer();

class _$CornerProgressResponseStatusEnumSerializer
    implements PrimitiveSerializer<CornerProgressResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'NOT_VISITED': 'NOT_VISITED',
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'NOT_VISITED': 'NOT_VISITED',
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };

  @override
  final Iterable<Type> types = const <Type>[CornerProgressResponseStatusEnum];
  @override
  final String wireName = 'CornerProgressResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, CornerProgressResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CornerProgressResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CornerProgressResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CornerProgressResponse extends CornerProgressResponse {
  @override
  final String? cornerId;
  @override
  final String? cornerName;
  @override
  final CornerProgressResponseStatusEnum? status;

  factory _$CornerProgressResponse(
          [void Function(CornerProgressResponseBuilder)? updates]) =>
      (CornerProgressResponseBuilder()..update(updates))._build();

  _$CornerProgressResponse._({this.cornerId, this.cornerName, this.status})
      : super._();
  @override
  CornerProgressResponse rebuild(
          void Function(CornerProgressResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerProgressResponseBuilder toBuilder() =>
      CornerProgressResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerProgressResponse &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerProgressResponse')
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName)
          ..add('status', status))
        .toString();
  }
}

class CornerProgressResponseBuilder
    implements Builder<CornerProgressResponse, CornerProgressResponseBuilder> {
  _$CornerProgressResponse? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  CornerProgressResponseStatusEnum? _status;
  CornerProgressResponseStatusEnum? get status => _$this._status;
  set status(CornerProgressResponseStatusEnum? status) =>
      _$this._status = status;

  CornerProgressResponseBuilder() {
    CornerProgressResponse._defaults(this);
  }

  CornerProgressResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerProgressResponse other) {
    _$v = other as _$CornerProgressResponse;
  }

  @override
  void update(void Function(CornerProgressResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerProgressResponse build() => _build();

  _$CornerProgressResponse _build() {
    final _$result = _$v ??
        _$CornerProgressResponse._(
          cornerId: cornerId,
          cornerName: cornerName,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
