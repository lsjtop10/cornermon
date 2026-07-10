// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VisitSummary extends VisitSummary {
  @override
  final String id;
  @override
  final String groupId;
  @override
  final String cornerId;
  @override
  final String trackId;
  @override
  final VisitStatus status;
  @override
  final VisitInputMethod? inputMethod;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final int? durationSeconds;
  @override
  final int? deviationSeconds;

  factory _$VisitSummary([void Function(VisitSummaryBuilder)? updates]) =>
      (VisitSummaryBuilder()..update(updates))._build();

  _$VisitSummary._({
    required this.id,
    required this.groupId,
    required this.cornerId,
    required this.trackId,
    required this.status,
    this.inputMethod,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.deviationSeconds,
  }) : super._();
  @override
  VisitSummary rebuild(void Function(VisitSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VisitSummaryBuilder toBuilder() => VisitSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VisitSummary &&
        id == other.id &&
        groupId == other.groupId &&
        cornerId == other.cornerId &&
        trackId == other.trackId &&
        status == other.status &&
        inputMethod == other.inputMethod &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        durationSeconds == other.durationSeconds &&
        deviationSeconds == other.deviationSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, inputMethod.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, durationSeconds.hashCode);
    _$hash = $jc(_$hash, deviationSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VisitSummary')
          ..add('id', id)
          ..add('groupId', groupId)
          ..add('cornerId', cornerId)
          ..add('trackId', trackId)
          ..add('status', status)
          ..add('inputMethod', inputMethod)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('durationSeconds', durationSeconds)
          ..add('deviationSeconds', deviationSeconds))
        .toString();
  }
}

class VisitSummaryBuilder
    implements Builder<VisitSummary, VisitSummaryBuilder> {
  _$VisitSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  VisitStatus? _status;
  VisitStatus? get status => _$this._status;
  set status(VisitStatus? status) => _$this._status = status;

  VisitInputMethod? _inputMethod;
  VisitInputMethod? get inputMethod => _$this._inputMethod;
  set inputMethod(VisitInputMethod? inputMethod) =>
      _$this._inputMethod = inputMethod;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  int? _durationSeconds;
  int? get durationSeconds => _$this._durationSeconds;
  set durationSeconds(int? durationSeconds) =>
      _$this._durationSeconds = durationSeconds;

  int? _deviationSeconds;
  int? get deviationSeconds => _$this._deviationSeconds;
  set deviationSeconds(int? deviationSeconds) =>
      _$this._deviationSeconds = deviationSeconds;

  VisitSummaryBuilder() {
    VisitSummary._defaults(this);
  }

  VisitSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _groupId = $v.groupId;
      _cornerId = $v.cornerId;
      _trackId = $v.trackId;
      _status = $v.status;
      _inputMethod = $v.inputMethod;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _durationSeconds = $v.durationSeconds;
      _deviationSeconds = $v.deviationSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VisitSummary other) {
    _$v = other as _$VisitSummary;
  }

  @override
  void update(void Function(VisitSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VisitSummary build() => _build();

  _$VisitSummary _build() {
    final _$result =
        _$v ??
        _$VisitSummary._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'VisitSummary', 'id'),
          groupId: BuiltValueNullFieldError.checkNotNull(
            groupId,
            r'VisitSummary',
            'groupId',
          ),
          cornerId: BuiltValueNullFieldError.checkNotNull(
            cornerId,
            r'VisitSummary',
            'cornerId',
          ),
          trackId: BuiltValueNullFieldError.checkNotNull(
            trackId,
            r'VisitSummary',
            'trackId',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'VisitSummary',
            'status',
          ),
          inputMethod: inputMethod,
          startedAt: BuiltValueNullFieldError.checkNotNull(
            startedAt,
            r'VisitSummary',
            'startedAt',
          ),
          endedAt: endedAt,
          durationSeconds: durationSeconds,
          deviationSeconds: deviationSeconds,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
