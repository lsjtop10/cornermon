// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

abstract mixin class TrackSummaryBuilder {
  void replace(TrackSummary other);
  void update(void Function(TrackSummaryBuilder) updates);
  String? get id;
  set id(String? id);

  String? get cornerId;
  set cornerId(String? cornerId);

  int? get trackNo;
  set trackNo(int? trackNo);

  TrackStatus? get status;
  set status(TrackStatus? status);

  TrackOperationalStatus? get operationalStatus;
  set operationalStatus(TrackOperationalStatus? operationalStatus);
}

class _$$TrackSummary extends $TrackSummary {
  @override
  final String id;
  @override
  final String cornerId;
  @override
  final int trackNo;
  @override
  final TrackStatus status;
  @override
  final TrackOperationalStatus? operationalStatus;

  factory _$$TrackSummary([void Function($TrackSummaryBuilder)? updates]) =>
      ($TrackSummaryBuilder()..update(updates))._build();

  _$$TrackSummary._({
    required this.id,
    required this.cornerId,
    required this.trackNo,
    required this.status,
    this.operationalStatus,
  }) : super._();
  @override
  $TrackSummary rebuild(void Function($TrackSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $TrackSummaryBuilder toBuilder() => $TrackSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $TrackSummary &&
        id == other.id &&
        cornerId == other.cornerId &&
        trackNo == other.trackNo &&
        status == other.status &&
        operationalStatus == other.operationalStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, operationalStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$TrackSummary')
          ..add('id', id)
          ..add('cornerId', cornerId)
          ..add('trackNo', trackNo)
          ..add('status', status)
          ..add('operationalStatus', operationalStatus))
        .toString();
  }
}

class $TrackSummaryBuilder
    implements
        Builder<$TrackSummary, $TrackSummaryBuilder>,
        TrackSummaryBuilder {
  _$$TrackSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(covariant String? cornerId) => _$this._cornerId = cornerId;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(covariant int? trackNo) => _$this._trackNo = trackNo;

  TrackStatus? _status;
  TrackStatus? get status => _$this._status;
  set status(covariant TrackStatus? status) => _$this._status = status;

  TrackOperationalStatus? _operationalStatus;
  TrackOperationalStatus? get operationalStatus => _$this._operationalStatus;
  set operationalStatus(covariant TrackOperationalStatus? operationalStatus) =>
      _$this._operationalStatus = operationalStatus;

  $TrackSummaryBuilder() {
    $TrackSummary._defaults(this);
  }

  $TrackSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _cornerId = $v.cornerId;
      _trackNo = $v.trackNo;
      _status = $v.status;
      _operationalStatus = $v.operationalStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $TrackSummary other) {
    _$v = other as _$$TrackSummary;
  }

  @override
  void update(void Function($TrackSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $TrackSummary build() => _build();

  _$$TrackSummary _build() {
    final _$result =
        _$v ??
        _$$TrackSummary._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'$TrackSummary', 'id'),
          cornerId: BuiltValueNullFieldError.checkNotNull(
            cornerId,
            r'$TrackSummary',
            'cornerId',
          ),
          trackNo: BuiltValueNullFieldError.checkNotNull(
            trackNo,
            r'$TrackSummary',
            'trackNo',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'$TrackSummary',
            'status',
          ),
          operationalStatus: operationalStatus,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
