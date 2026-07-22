// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'sse_scope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SSEScopeKindEnum _$sSEScopeKindEnum_camp =
    const SSEScopeKindEnum._('camp');
const SSEScopeKindEnum _$sSEScopeKindEnum_track =
    const SSEScopeKindEnum._('track');

SSEScopeKindEnum _$sSEScopeKindEnumValueOf(String name) {
  switch (name) {
    case 'camp':
      return _$sSEScopeKindEnum_camp;
    case 'track':
      return _$sSEScopeKindEnum_track;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SSEScopeKindEnum> _$sSEScopeKindEnumValues =
    BuiltSet<SSEScopeKindEnum>(const <SSEScopeKindEnum>[
  _$sSEScopeKindEnum_camp,
  _$sSEScopeKindEnum_track,
]);

Serializer<SSEScopeKindEnum> _$sSEScopeKindEnumSerializer =
    _$SSEScopeKindEnumSerializer();

class _$SSEScopeKindEnumSerializer
    implements PrimitiveSerializer<SSEScopeKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'camp': 'camp',
    'track': 'track',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'camp': 'camp',
    'track': 'track',
  };

  @override
  final Iterable<Type> types = const <Type>[SSEScopeKindEnum];
  @override
  final String wireName = 'SSEScopeKindEnum';

  @override
  Object serialize(Serializers serializers, SSEScopeKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SSEScopeKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SSEScopeKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SSEScope extends SSEScope {
  @override
  final SSEScopeKindEnum? kind;
  @override
  final String? trackId;

  factory _$SSEScope([void Function(SSEScopeBuilder)? updates]) =>
      (SSEScopeBuilder()..update(updates))._build();

  _$SSEScope._({this.kind, this.trackId}) : super._();
  @override
  SSEScope rebuild(void Function(SSEScopeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SSEScopeBuilder toBuilder() => SSEScopeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SSEScope && kind == other.kind && trackId == other.trackId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SSEScope')
          ..add('kind', kind)
          ..add('trackId', trackId))
        .toString();
  }
}

class SSEScopeBuilder implements Builder<SSEScope, SSEScopeBuilder> {
  _$SSEScope? _$v;

  SSEScopeKindEnum? _kind;
  SSEScopeKindEnum? get kind => _$this._kind;
  set kind(SSEScopeKindEnum? kind) => _$this._kind = kind;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  SSEScopeBuilder() {
    SSEScope._defaults(this);
  }

  SSEScopeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _trackId = $v.trackId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SSEScope other) {
    _$v = other as _$SSEScope;
  }

  @override
  void update(void Function(SSEScopeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SSEScope build() => _build();

  _$SSEScope _build() {
    final _$result = _$v ??
        _$SSEScope._(
          kind: kind,
          trackId: trackId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
