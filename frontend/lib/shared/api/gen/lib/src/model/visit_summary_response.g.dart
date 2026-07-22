// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'visit_summary_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VisitSummaryResponseInputMethodEnum
    _$visitSummaryResponseInputMethodEnum_QR_SCAN =
    const VisitSummaryResponseInputMethodEnum._('QR_SCAN');
const VisitSummaryResponseInputMethodEnum
    _$visitSummaryResponseInputMethodEnum_MANUAL =
    const VisitSummaryResponseInputMethodEnum._('MANUAL');

VisitSummaryResponseInputMethodEnum
    _$visitSummaryResponseInputMethodEnumValueOf(String name) {
  switch (name) {
    case 'QR_SCAN':
      return _$visitSummaryResponseInputMethodEnum_QR_SCAN;
    case 'MANUAL':
      return _$visitSummaryResponseInputMethodEnum_MANUAL;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VisitSummaryResponseInputMethodEnum>
    _$visitSummaryResponseInputMethodEnumValues = BuiltSet<
        VisitSummaryResponseInputMethodEnum>(const <VisitSummaryResponseInputMethodEnum>[
  _$visitSummaryResponseInputMethodEnum_QR_SCAN,
  _$visitSummaryResponseInputMethodEnum_MANUAL,
]);

const VisitSummaryResponseStatusEnum
    _$visitSummaryResponseStatusEnum_IN_PROGRESS =
    const VisitSummaryResponseStatusEnum._('IN_PROGRESS');
const VisitSummaryResponseStatusEnum
    _$visitSummaryResponseStatusEnum_COMPLETED =
    const VisitSummaryResponseStatusEnum._('COMPLETED');

VisitSummaryResponseStatusEnum _$visitSummaryResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'IN_PROGRESS':
      return _$visitSummaryResponseStatusEnum_IN_PROGRESS;
    case 'COMPLETED':
      return _$visitSummaryResponseStatusEnum_COMPLETED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VisitSummaryResponseStatusEnum>
    _$visitSummaryResponseStatusEnumValues = BuiltSet<
        VisitSummaryResponseStatusEnum>(const <VisitSummaryResponseStatusEnum>[
  _$visitSummaryResponseStatusEnum_IN_PROGRESS,
  _$visitSummaryResponseStatusEnum_COMPLETED,
]);

Serializer<VisitSummaryResponseInputMethodEnum>
    _$visitSummaryResponseInputMethodEnumSerializer =
    _$VisitSummaryResponseInputMethodEnumSerializer();
Serializer<VisitSummaryResponseStatusEnum>
    _$visitSummaryResponseStatusEnumSerializer =
    _$VisitSummaryResponseStatusEnumSerializer();

class _$VisitSummaryResponseInputMethodEnumSerializer
    implements PrimitiveSerializer<VisitSummaryResponseInputMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'QR_SCAN': 'QR_SCAN',
    'MANUAL': 'MANUAL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'QR_SCAN': 'QR_SCAN',
    'MANUAL': 'MANUAL',
  };

  @override
  final Iterable<Type> types = const <Type>[
    VisitSummaryResponseInputMethodEnum
  ];
  @override
  final String wireName = 'VisitSummaryResponseInputMethodEnum';

  @override
  Object serialize(
          Serializers serializers, VisitSummaryResponseInputMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VisitSummaryResponseInputMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VisitSummaryResponseInputMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VisitSummaryResponseStatusEnumSerializer
    implements PrimitiveSerializer<VisitSummaryResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };

  @override
  final Iterable<Type> types = const <Type>[VisitSummaryResponseStatusEnum];
  @override
  final String wireName = 'VisitSummaryResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, VisitSummaryResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VisitSummaryResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VisitSummaryResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VisitSummaryResponse extends VisitSummaryResponse {
  @override
  final String? cornerId;
  @override
  final int? deviationSeconds;
  @override
  final int? durationSeconds;
  @override
  final DateTime? endedAt;
  @override
  final String? groupId;
  @override
  final String? id;
  @override
  final VisitSummaryResponseInputMethodEnum? inputMethod;
  @override
  final DateTime? startedAt;
  @override
  final VisitSummaryResponseStatusEnum? status;
  @override
  final String? trackId;

  factory _$VisitSummaryResponse(
          [void Function(VisitSummaryResponseBuilder)? updates]) =>
      (VisitSummaryResponseBuilder()..update(updates))._build();

  _$VisitSummaryResponse._(
      {this.cornerId,
      this.deviationSeconds,
      this.durationSeconds,
      this.endedAt,
      this.groupId,
      this.id,
      this.inputMethod,
      this.startedAt,
      this.status,
      this.trackId})
      : super._();
  @override
  VisitSummaryResponse rebuild(
          void Function(VisitSummaryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VisitSummaryResponseBuilder toBuilder() =>
      VisitSummaryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VisitSummaryResponse &&
        cornerId == other.cornerId &&
        deviationSeconds == other.deviationSeconds &&
        durationSeconds == other.durationSeconds &&
        endedAt == other.endedAt &&
        groupId == other.groupId &&
        id == other.id &&
        inputMethod == other.inputMethod &&
        startedAt == other.startedAt &&
        status == other.status &&
        trackId == other.trackId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, deviationSeconds.hashCode);
    _$hash = $jc(_$hash, durationSeconds.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, inputMethod.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VisitSummaryResponse')
          ..add('cornerId', cornerId)
          ..add('deviationSeconds', deviationSeconds)
          ..add('durationSeconds', durationSeconds)
          ..add('endedAt', endedAt)
          ..add('groupId', groupId)
          ..add('id', id)
          ..add('inputMethod', inputMethod)
          ..add('startedAt', startedAt)
          ..add('status', status)
          ..add('trackId', trackId))
        .toString();
  }
}

class VisitSummaryResponseBuilder
    implements Builder<VisitSummaryResponse, VisitSummaryResponseBuilder> {
  _$VisitSummaryResponse? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  int? _deviationSeconds;
  int? get deviationSeconds => _$this._deviationSeconds;
  set deviationSeconds(int? deviationSeconds) =>
      _$this._deviationSeconds = deviationSeconds;

  int? _durationSeconds;
  int? get durationSeconds => _$this._durationSeconds;
  set durationSeconds(int? durationSeconds) =>
      _$this._durationSeconds = durationSeconds;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  VisitSummaryResponseInputMethodEnum? _inputMethod;
  VisitSummaryResponseInputMethodEnum? get inputMethod => _$this._inputMethod;
  set inputMethod(VisitSummaryResponseInputMethodEnum? inputMethod) =>
      _$this._inputMethod = inputMethod;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  VisitSummaryResponseStatusEnum? _status;
  VisitSummaryResponseStatusEnum? get status => _$this._status;
  set status(VisitSummaryResponseStatusEnum? status) => _$this._status = status;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  VisitSummaryResponseBuilder() {
    VisitSummaryResponse._defaults(this);
  }

  VisitSummaryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _deviationSeconds = $v.deviationSeconds;
      _durationSeconds = $v.durationSeconds;
      _endedAt = $v.endedAt;
      _groupId = $v.groupId;
      _id = $v.id;
      _inputMethod = $v.inputMethod;
      _startedAt = $v.startedAt;
      _status = $v.status;
      _trackId = $v.trackId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VisitSummaryResponse other) {
    _$v = other as _$VisitSummaryResponse;
  }

  @override
  void update(void Function(VisitSummaryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VisitSummaryResponse build() => _build();

  _$VisitSummaryResponse _build() {
    final _$result = _$v ??
        _$VisitSummaryResponse._(
          cornerId: cornerId,
          deviationSeconds: deviationSeconds,
          durationSeconds: durationSeconds,
          endedAt: endedAt,
          groupId: groupId,
          id: id,
          inputMethod: inputMethod,
          startedAt: startedAt,
          status: status,
          trackId: trackId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
