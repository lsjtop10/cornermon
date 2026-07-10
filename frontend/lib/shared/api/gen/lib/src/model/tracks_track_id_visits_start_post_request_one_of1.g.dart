// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_track_id_visits_start_post_request_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum
_$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnum_MANUAL =
    const TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum._('MANUAL');

TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum
_$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnumValueOf(String name) {
  switch (name) {
    case 'MANUAL':
      return _$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnum_MANUAL;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum>
_$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnumValues =
    BuiltSet<TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum>(
      const <TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum>[
        _$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnum_MANUAL,
      ],
    );

Serializer<TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum>
_$tracksTrackIdVisitsStartPostRequestOneOf1MethodEnumSerializer =
    _$TracksTrackIdVisitsStartPostRequestOneOf1MethodEnumSerializer();

class _$TracksTrackIdVisitsStartPostRequestOneOf1MethodEnumSerializer
    implements
        PrimitiveSerializer<
          TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum
        > {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MANUAL': 'MANUAL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MANUAL': 'MANUAL',
  };

  @override
  final Iterable<Type> types = const <Type>[
    TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum,
  ];
  @override
  final String wireName = 'TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum';

  @override
  Object serialize(
    Serializers serializers,
    TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TracksTrackIdVisitsStartPostRequestOneOf1
    extends TracksTrackIdVisitsStartPostRequestOneOf1 {
  @override
  final String groupId;
  @override
  final TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum method;

  factory _$TracksTrackIdVisitsStartPostRequestOneOf1([
    void Function(TracksTrackIdVisitsStartPostRequestOneOf1Builder)? updates,
  ]) => (TracksTrackIdVisitsStartPostRequestOneOf1Builder()..update(updates))
      ._build();

  _$TracksTrackIdVisitsStartPostRequestOneOf1._({
    required this.groupId,
    required this.method,
  }) : super._();
  @override
  TracksTrackIdVisitsStartPostRequestOneOf1 rebuild(
    void Function(TracksTrackIdVisitsStartPostRequestOneOf1Builder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  TracksTrackIdVisitsStartPostRequestOneOf1Builder toBuilder() =>
      TracksTrackIdVisitsStartPostRequestOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TracksTrackIdVisitsStartPostRequestOneOf1 &&
        groupId == other.groupId &&
        method == other.method;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'TracksTrackIdVisitsStartPostRequestOneOf1',
          )
          ..add('groupId', groupId)
          ..add('method', method))
        .toString();
  }
}

class TracksTrackIdVisitsStartPostRequestOneOf1Builder
    implements
        Builder<
          TracksTrackIdVisitsStartPostRequestOneOf1,
          TracksTrackIdVisitsStartPostRequestOneOf1Builder
        > {
  _$TracksTrackIdVisitsStartPostRequestOneOf1? _$v;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum? _method;
  TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum? get method =>
      _$this._method;
  set method(TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum? method) =>
      _$this._method = method;

  TracksTrackIdVisitsStartPostRequestOneOf1Builder() {
    TracksTrackIdVisitsStartPostRequestOneOf1._defaults(this);
  }

  TracksTrackIdVisitsStartPostRequestOneOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _groupId = $v.groupId;
      _method = $v.method;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TracksTrackIdVisitsStartPostRequestOneOf1 other) {
    _$v = other as _$TracksTrackIdVisitsStartPostRequestOneOf1;
  }

  @override
  void update(
    void Function(TracksTrackIdVisitsStartPostRequestOneOf1Builder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  TracksTrackIdVisitsStartPostRequestOneOf1 build() => _build();

  _$TracksTrackIdVisitsStartPostRequestOneOf1 _build() {
    final _$result =
        _$v ??
        _$TracksTrackIdVisitsStartPostRequestOneOf1._(
          groupId: BuiltValueNullFieldError.checkNotNull(
            groupId,
            r'TracksTrackIdVisitsStartPostRequestOneOf1',
            'groupId',
          ),
          method: BuiltValueNullFieldError.checkNotNull(
            method,
            r'TracksTrackIdVisitsStartPostRequestOneOf1',
            'method',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
