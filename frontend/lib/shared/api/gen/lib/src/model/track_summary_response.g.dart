// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_summary_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TrackSummaryResponseOperationalStatusEnum
    _$trackSummaryResponseOperationalStatusEnum_IDLE =
    const TrackSummaryResponseOperationalStatusEnum._('IDLE');
const TrackSummaryResponseOperationalStatusEnum
    _$trackSummaryResponseOperationalStatusEnum_BUSY =
    const TrackSummaryResponseOperationalStatusEnum._('BUSY');

TrackSummaryResponseOperationalStatusEnum
    _$trackSummaryResponseOperationalStatusEnumValueOf(String name) {
  switch (name) {
    case 'IDLE':
      return _$trackSummaryResponseOperationalStatusEnum_IDLE;
    case 'BUSY':
      return _$trackSummaryResponseOperationalStatusEnum_BUSY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackSummaryResponseOperationalStatusEnum>
    _$trackSummaryResponseOperationalStatusEnumValues = BuiltSet<
        TrackSummaryResponseOperationalStatusEnum>(const <TrackSummaryResponseOperationalStatusEnum>[
  _$trackSummaryResponseOperationalStatusEnum_IDLE,
  _$trackSummaryResponseOperationalStatusEnum_BUSY,
]);

const TrackSummaryResponseStatusEnum _$trackSummaryResponseStatusEnum_ACTIVE =
    const TrackSummaryResponseStatusEnum._('ACTIVE');
const TrackSummaryResponseStatusEnum _$trackSummaryResponseStatusEnum_DELETED =
    const TrackSummaryResponseStatusEnum._('DELETED');

TrackSummaryResponseStatusEnum _$trackSummaryResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'ACTIVE':
      return _$trackSummaryResponseStatusEnum_ACTIVE;
    case 'DELETED':
      return _$trackSummaryResponseStatusEnum_DELETED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackSummaryResponseStatusEnum>
    _$trackSummaryResponseStatusEnumValues = BuiltSet<
        TrackSummaryResponseStatusEnum>(const <TrackSummaryResponseStatusEnum>[
  _$trackSummaryResponseStatusEnum_ACTIVE,
  _$trackSummaryResponseStatusEnum_DELETED,
]);

Serializer<TrackSummaryResponseOperationalStatusEnum>
    _$trackSummaryResponseOperationalStatusEnumSerializer =
    _$TrackSummaryResponseOperationalStatusEnumSerializer();
Serializer<TrackSummaryResponseStatusEnum>
    _$trackSummaryResponseStatusEnumSerializer =
    _$TrackSummaryResponseStatusEnumSerializer();

class _$TrackSummaryResponseOperationalStatusEnumSerializer
    implements PrimitiveSerializer<TrackSummaryResponseOperationalStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IDLE': 'IDLE',
    'BUSY': 'BUSY',
  };

  @override
  final Iterable<Type> types = const <Type>[
    TrackSummaryResponseOperationalStatusEnum
  ];
  @override
  final String wireName = 'TrackSummaryResponseOperationalStatusEnum';

  @override
  Object serialize(Serializers serializers,
          TrackSummaryResponseOperationalStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackSummaryResponseOperationalStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackSummaryResponseOperationalStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackSummaryResponseStatusEnumSerializer
    implements PrimitiveSerializer<TrackSummaryResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'DELETED': 'DELETED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'DELETED': 'DELETED',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackSummaryResponseStatusEnum];
  @override
  final String wireName = 'TrackSummaryResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, TrackSummaryResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackSummaryResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackSummaryResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackSummaryResponse extends TrackSummaryResponse {
  @override
  final String? cornerId;
  @override
  final String? id;
  @override
  final TrackSummaryResponseOperationalStatusEnum? operationalStatus;
  @override
  final TrackSummaryResponseStatusEnum? status;
  @override
  final int? trackNo;

  factory _$TrackSummaryResponse(
          [void Function(TrackSummaryResponseBuilder)? updates]) =>
      (TrackSummaryResponseBuilder()..update(updates))._build();

  _$TrackSummaryResponse._(
      {this.cornerId,
      this.id,
      this.operationalStatus,
      this.status,
      this.trackNo})
      : super._();
  @override
  TrackSummaryResponse rebuild(
          void Function(TrackSummaryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackSummaryResponseBuilder toBuilder() =>
      TrackSummaryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackSummaryResponse &&
        cornerId == other.cornerId &&
        id == other.id &&
        operationalStatus == other.operationalStatus &&
        status == other.status &&
        trackNo == other.trackNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, operationalStatus.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackSummaryResponse')
          ..add('cornerId', cornerId)
          ..add('id', id)
          ..add('operationalStatus', operationalStatus)
          ..add('status', status)
          ..add('trackNo', trackNo))
        .toString();
  }
}

class TrackSummaryResponseBuilder
    implements Builder<TrackSummaryResponse, TrackSummaryResponseBuilder> {
  _$TrackSummaryResponse? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  TrackSummaryResponseOperationalStatusEnum? _operationalStatus;
  TrackSummaryResponseOperationalStatusEnum? get operationalStatus =>
      _$this._operationalStatus;
  set operationalStatus(
          TrackSummaryResponseOperationalStatusEnum? operationalStatus) =>
      _$this._operationalStatus = operationalStatus;

  TrackSummaryResponseStatusEnum? _status;
  TrackSummaryResponseStatusEnum? get status => _$this._status;
  set status(TrackSummaryResponseStatusEnum? status) => _$this._status = status;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(int? trackNo) => _$this._trackNo = trackNo;

  TrackSummaryResponseBuilder() {
    TrackSummaryResponse._defaults(this);
  }

  TrackSummaryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _id = $v.id;
      _operationalStatus = $v.operationalStatus;
      _status = $v.status;
      _trackNo = $v.trackNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackSummaryResponse other) {
    _$v = other as _$TrackSummaryResponse;
  }

  @override
  void update(void Function(TrackSummaryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackSummaryResponse build() => _build();

  _$TrackSummaryResponse _build() {
    final _$result = _$v ??
        _$TrackSummaryResponse._(
          cornerId: cornerId,
          id: id,
          operationalStatus: operationalStatus,
          status: status,
          trackNo: trackNo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
