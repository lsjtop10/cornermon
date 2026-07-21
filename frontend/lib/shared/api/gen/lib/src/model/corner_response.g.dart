// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'corner_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CornerResponseStatusEnum _$cornerResponseStatusEnum_INACTIVE =
    const CornerResponseStatusEnum._('INACTIVE');
const CornerResponseStatusEnum _$cornerResponseStatusEnum_IDLE =
    const CornerResponseStatusEnum._('IDLE');
const CornerResponseStatusEnum _$cornerResponseStatusEnum_BUSY =
    const CornerResponseStatusEnum._('BUSY');

CornerResponseStatusEnum _$cornerResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'INACTIVE':
      return _$cornerResponseStatusEnum_INACTIVE;
    case 'IDLE':
      return _$cornerResponseStatusEnum_IDLE;
    case 'BUSY':
      return _$cornerResponseStatusEnum_BUSY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CornerResponseStatusEnum> _$cornerResponseStatusEnumValues =
    BuiltSet<CornerResponseStatusEnum>(const <CornerResponseStatusEnum>[
  _$cornerResponseStatusEnum_INACTIVE,
  _$cornerResponseStatusEnum_IDLE,
  _$cornerResponseStatusEnum_BUSY,
]);

Serializer<CornerResponseStatusEnum> _$cornerResponseStatusEnumSerializer =
    _$CornerResponseStatusEnumSerializer();

class _$CornerResponseStatusEnumSerializer
    implements PrimitiveSerializer<CornerResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INACTIVE': 'INACTIVE',
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INACTIVE': 'INACTIVE',
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };

  @override
  final Iterable<Type> types = const <Type>[CornerResponseStatusEnum];
  @override
  final String wireName = 'CornerResponseStatusEnum';

  @override
  Object serialize(Serializers serializers, CornerResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CornerResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CornerResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CornerResponse extends CornerResponse {
  @override
  final BuiltList<TrackSummaryResponse>? activeTracks;
  @override
  final String? campId;
  @override
  final CornerMetricResponse? cornerMetric;
  @override
  final String? id;
  @override
  final bool? isBottleneck;
  @override
  final String? name;
  @override
  final CornerResponseStatusEnum? status;
  @override
  final int? targetMinutes;

  factory _$CornerResponse([void Function(CornerResponseBuilder)? updates]) =>
      (CornerResponseBuilder()..update(updates))._build();

  _$CornerResponse._(
      {this.activeTracks,
      this.campId,
      this.cornerMetric,
      this.id,
      this.isBottleneck,
      this.name,
      this.status,
      this.targetMinutes})
      : super._();
  @override
  CornerResponse rebuild(void Function(CornerResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerResponseBuilder toBuilder() => CornerResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerResponse &&
        activeTracks == other.activeTracks &&
        campId == other.campId &&
        cornerMetric == other.cornerMetric &&
        id == other.id &&
        isBottleneck == other.isBottleneck &&
        name == other.name &&
        status == other.status &&
        targetMinutes == other.targetMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeTracks.hashCode);
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, cornerMetric.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isBottleneck.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, targetMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerResponse')
          ..add('activeTracks', activeTracks)
          ..add('campId', campId)
          ..add('cornerMetric', cornerMetric)
          ..add('id', id)
          ..add('isBottleneck', isBottleneck)
          ..add('name', name)
          ..add('status', status)
          ..add('targetMinutes', targetMinutes))
        .toString();
  }
}

class CornerResponseBuilder
    implements Builder<CornerResponse, CornerResponseBuilder> {
  _$CornerResponse? _$v;

  ListBuilder<TrackSummaryResponse>? _activeTracks;
  ListBuilder<TrackSummaryResponse> get activeTracks =>
      _$this._activeTracks ??= ListBuilder<TrackSummaryResponse>();
  set activeTracks(ListBuilder<TrackSummaryResponse>? activeTracks) =>
      _$this._activeTracks = activeTracks;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  CornerMetricResponseBuilder? _cornerMetric;
  CornerMetricResponseBuilder get cornerMetric =>
      _$this._cornerMetric ??= CornerMetricResponseBuilder();
  set cornerMetric(CornerMetricResponseBuilder? cornerMetric) =>
      _$this._cornerMetric = cornerMetric;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isBottleneck;
  bool? get isBottleneck => _$this._isBottleneck;
  set isBottleneck(bool? isBottleneck) => _$this._isBottleneck = isBottleneck;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CornerResponseStatusEnum? _status;
  CornerResponseStatusEnum? get status => _$this._status;
  set status(CornerResponseStatusEnum? status) => _$this._status = status;

  int? _targetMinutes;
  int? get targetMinutes => _$this._targetMinutes;
  set targetMinutes(int? targetMinutes) =>
      _$this._targetMinutes = targetMinutes;

  CornerResponseBuilder() {
    CornerResponse._defaults(this);
  }

  CornerResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeTracks = $v.activeTracks?.toBuilder();
      _campId = $v.campId;
      _cornerMetric = $v.cornerMetric?.toBuilder();
      _id = $v.id;
      _isBottleneck = $v.isBottleneck;
      _name = $v.name;
      _status = $v.status;
      _targetMinutes = $v.targetMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerResponse other) {
    _$v = other as _$CornerResponse;
  }

  @override
  void update(void Function(CornerResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerResponse build() => _build();

  _$CornerResponse _build() {
    _$CornerResponse _$result;
    try {
      _$result = _$v ??
          _$CornerResponse._(
            activeTracks: _activeTracks?.build(),
            campId: campId,
            cornerMetric: _cornerMetric?.build(),
            id: id,
            isBottleneck: isBottleneck,
            name: name,
            status: status,
            targetMinutes: targetMinutes,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeTracks';
        _activeTracks?.build();

        _$failedField = 'cornerMetric';
        _cornerMetric?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CornerResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
