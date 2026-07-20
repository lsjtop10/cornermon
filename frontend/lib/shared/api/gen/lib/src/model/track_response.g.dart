// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'track_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TrackResponseOperationalStatusEnum
    _$trackResponseOperationalStatusEnum_IDLE =
    const TrackResponseOperationalStatusEnum._('IDLE');
const TrackResponseOperationalStatusEnum
    _$trackResponseOperationalStatusEnum_BUSY =
    const TrackResponseOperationalStatusEnum._('BUSY');

TrackResponseOperationalStatusEnum _$trackResponseOperationalStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'IDLE':
      return _$trackResponseOperationalStatusEnum_IDLE;
    case 'BUSY':
      return _$trackResponseOperationalStatusEnum_BUSY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackResponseOperationalStatusEnum>
    _$trackResponseOperationalStatusEnumValues = BuiltSet<
        TrackResponseOperationalStatusEnum>(const <TrackResponseOperationalStatusEnum>[
  _$trackResponseOperationalStatusEnum_IDLE,
  _$trackResponseOperationalStatusEnum_BUSY,
]);

const TrackResponseStatusEnum _$trackResponseStatusEnum_ACTIVE =
    const TrackResponseStatusEnum._('ACTIVE');
const TrackResponseStatusEnum _$trackResponseStatusEnum_DELETED =
    const TrackResponseStatusEnum._('DELETED');

TrackResponseStatusEnum _$trackResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$trackResponseStatusEnum_ACTIVE;
    case 'DELETED':
      return _$trackResponseStatusEnum_DELETED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackResponseStatusEnum> _$trackResponseStatusEnumValues =
    BuiltSet<TrackResponseStatusEnum>(const <TrackResponseStatusEnum>[
  _$trackResponseStatusEnum_ACTIVE,
  _$trackResponseStatusEnum_DELETED,
]);

Serializer<TrackResponseOperationalStatusEnum>
    _$trackResponseOperationalStatusEnumSerializer =
    _$TrackResponseOperationalStatusEnumSerializer();
Serializer<TrackResponseStatusEnum> _$trackResponseStatusEnumSerializer =
    _$TrackResponseStatusEnumSerializer();

class _$TrackResponseOperationalStatusEnumSerializer
    implements PrimitiveSerializer<TrackResponseOperationalStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackResponseOperationalStatusEnum];
  @override
  final String wireName = 'TrackResponseOperationalStatusEnum';

  @override
  Object serialize(
          Serializers serializers, TrackResponseOperationalStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackResponseOperationalStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackResponseOperationalStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackResponseStatusEnumSerializer
    implements PrimitiveSerializer<TrackResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'DELETED': 'DELETED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'DELETED': 'DELETED',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackResponseStatusEnum];
  @override
  final String wireName = 'TrackResponseStatusEnum';

  @override
  Object serialize(Serializers serializers, TrackResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackResponse extends TrackResponse {
  @override
  final String? cornerId;
  @override
  final VisitSummaryResponse? currentVisit;
  @override
  final String? id;
  @override
  final TrackResponseOperationalStatusEnum? operationalStatus;
  @override
  final TrackResponseStatusEnum? status;
  @override
  final int? trackNo;

  factory _$TrackResponse([void Function(TrackResponseBuilder)? updates]) =>
      (TrackResponseBuilder()..update(updates))._build();

  _$TrackResponse._(
      {this.cornerId,
      this.currentVisit,
      this.id,
      this.operationalStatus,
      this.status,
      this.trackNo})
      : super._();
  @override
  TrackResponse rebuild(void Function(TrackResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackResponseBuilder toBuilder() => TrackResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackResponse &&
        cornerId == other.cornerId &&
        currentVisit == other.currentVisit &&
        id == other.id &&
        operationalStatus == other.operationalStatus &&
        status == other.status &&
        trackNo == other.trackNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, currentVisit.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, operationalStatus.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackResponse')
          ..add('cornerId', cornerId)
          ..add('currentVisit', currentVisit)
          ..add('id', id)
          ..add('operationalStatus', operationalStatus)
          ..add('status', status)
          ..add('trackNo', trackNo))
        .toString();
  }
}

class TrackResponseBuilder
    implements Builder<TrackResponse, TrackResponseBuilder> {
  _$TrackResponse? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  VisitSummaryResponseBuilder? _currentVisit;
  VisitSummaryResponseBuilder get currentVisit =>
      _$this._currentVisit ??= VisitSummaryResponseBuilder();
  set currentVisit(VisitSummaryResponseBuilder? currentVisit) =>
      _$this._currentVisit = currentVisit;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  TrackResponseOperationalStatusEnum? _operationalStatus;
  TrackResponseOperationalStatusEnum? get operationalStatus =>
      _$this._operationalStatus;
  set operationalStatus(
          TrackResponseOperationalStatusEnum? operationalStatus) =>
      _$this._operationalStatus = operationalStatus;

  TrackResponseStatusEnum? _status;
  TrackResponseStatusEnum? get status => _$this._status;
  set status(TrackResponseStatusEnum? status) => _$this._status = status;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(int? trackNo) => _$this._trackNo = trackNo;

  TrackResponseBuilder() {
    TrackResponse._defaults(this);
  }

  TrackResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _currentVisit = $v.currentVisit?.toBuilder();
      _id = $v.id;
      _operationalStatus = $v.operationalStatus;
      _status = $v.status;
      _trackNo = $v.trackNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackResponse other) {
    _$v = other as _$TrackResponse;
  }

  @override
  void update(void Function(TrackResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackResponse build() => _build();

  _$TrackResponse _build() {
    _$TrackResponse _$result;
    try {
      _$result = _$v ??
          _$TrackResponse._(
            cornerId: cornerId,
            currentVisit: _currentVisit?.build(),
            id: id,
            operationalStatus: operationalStatus,
            status: status,
            trackNo: trackNo,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'currentVisit';
        _currentVisit?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
