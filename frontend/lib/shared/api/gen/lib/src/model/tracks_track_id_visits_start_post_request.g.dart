// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_track_id_visits_start_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TracksTrackIdVisitsStartPostRequestMethodEnum
    _$tracksTrackIdVisitsStartPostRequestMethodEnum_MANUAL =
    const TracksTrackIdVisitsStartPostRequestMethodEnum._('MANUAL');

TracksTrackIdVisitsStartPostRequestMethodEnum
    _$tracksTrackIdVisitsStartPostRequestMethodEnumValueOf(String name) {
  switch (name) {
    case 'MANUAL':
      return _$tracksTrackIdVisitsStartPostRequestMethodEnum_MANUAL;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TracksTrackIdVisitsStartPostRequestMethodEnum>
    _$tracksTrackIdVisitsStartPostRequestMethodEnumValues = BuiltSet<
        TracksTrackIdVisitsStartPostRequestMethodEnum>(const <TracksTrackIdVisitsStartPostRequestMethodEnum>[
  _$tracksTrackIdVisitsStartPostRequestMethodEnum_MANUAL,
]);

Serializer<TracksTrackIdVisitsStartPostRequestMethodEnum>
    _$tracksTrackIdVisitsStartPostRequestMethodEnumSerializer =
    _$TracksTrackIdVisitsStartPostRequestMethodEnumSerializer();

class _$TracksTrackIdVisitsStartPostRequestMethodEnumSerializer
    implements
        PrimitiveSerializer<TracksTrackIdVisitsStartPostRequestMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MANUAL': 'MANUAL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MANUAL': 'MANUAL',
  };

  @override
  final Iterable<Type> types = const <Type>[
    TracksTrackIdVisitsStartPostRequestMethodEnum
  ];
  @override
  final String wireName = 'TracksTrackIdVisitsStartPostRequestMethodEnum';

  @override
  Object serialize(Serializers serializers,
          TracksTrackIdVisitsStartPostRequestMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TracksTrackIdVisitsStartPostRequestMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TracksTrackIdVisitsStartPostRequestMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TracksTrackIdVisitsStartPostRequest
    extends TracksTrackIdVisitsStartPostRequest {
  @override
  final OneOf oneOf;

  factory _$TracksTrackIdVisitsStartPostRequest(
          [void Function(TracksTrackIdVisitsStartPostRequestBuilder)?
              updates]) =>
      (TracksTrackIdVisitsStartPostRequestBuilder()..update(updates))._build();

  _$TracksTrackIdVisitsStartPostRequest._({required this.oneOf}) : super._();
  @override
  TracksTrackIdVisitsStartPostRequest rebuild(
          void Function(TracksTrackIdVisitsStartPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TracksTrackIdVisitsStartPostRequestBuilder toBuilder() =>
      TracksTrackIdVisitsStartPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TracksTrackIdVisitsStartPostRequest && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TracksTrackIdVisitsStartPostRequest')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class TracksTrackIdVisitsStartPostRequestBuilder
    implements
        Builder<TracksTrackIdVisitsStartPostRequest,
            TracksTrackIdVisitsStartPostRequestBuilder> {
  _$TracksTrackIdVisitsStartPostRequest? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  TracksTrackIdVisitsStartPostRequestBuilder() {
    TracksTrackIdVisitsStartPostRequest._defaults(this);
  }

  TracksTrackIdVisitsStartPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TracksTrackIdVisitsStartPostRequest other) {
    _$v = other as _$TracksTrackIdVisitsStartPostRequest;
  }

  @override
  void update(
      void Function(TracksTrackIdVisitsStartPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TracksTrackIdVisitsStartPostRequest build() => _build();

  _$TracksTrackIdVisitsStartPostRequest _build() {
    final _$result = _$v ??
        _$TracksTrackIdVisitsStartPostRequest._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'TracksTrackIdVisitsStartPostRequest', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
