// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Track extends Track {
  @override
  final String? pin;
  @override
  final VisitSummary? currentVisit;
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

  factory _$Track([void Function(TrackBuilder)? updates]) =>
      (TrackBuilder()..update(updates))._build();

  _$Track._(
      {this.pin,
      this.currentVisit,
      required this.id,
      required this.cornerId,
      required this.trackNo,
      required this.status,
      this.operationalStatus})
      : super._();
  @override
  Track rebuild(void Function(TrackBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackBuilder toBuilder() => TrackBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Track &&
        pin == other.pin &&
        currentVisit == other.currentVisit &&
        id == other.id &&
        cornerId == other.cornerId &&
        trackNo == other.trackNo &&
        status == other.status &&
        operationalStatus == other.operationalStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, currentVisit.hashCode);
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
    return (newBuiltValueToStringHelper(r'Track')
          ..add('pin', pin)
          ..add('currentVisit', currentVisit)
          ..add('id', id)
          ..add('cornerId', cornerId)
          ..add('trackNo', trackNo)
          ..add('status', status)
          ..add('operationalStatus', operationalStatus))
        .toString();
  }
}

class TrackBuilder
    implements Builder<Track, TrackBuilder>, TrackSummaryBuilder {
  _$Track? _$v;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(covariant String? pin) => _$this._pin = pin;

  VisitSummaryBuilder? _currentVisit;
  VisitSummaryBuilder get currentVisit =>
      _$this._currentVisit ??= VisitSummaryBuilder();
  set currentVisit(covariant VisitSummaryBuilder? currentVisit) =>
      _$this._currentVisit = currentVisit;

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

  TrackBuilder() {
    Track._defaults(this);
  }

  TrackBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pin = $v.pin;
      _currentVisit = $v.currentVisit?.toBuilder();
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
  void replace(covariant Track other) {
    _$v = other as _$Track;
  }

  @override
  void update(void Function(TrackBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Track build() => _build();

  _$Track _build() {
    _$Track _$result;
    try {
      _$result = _$v ??
          _$Track._(
            pin: pin,
            currentVisit: _currentVisit?.build(),
            id: BuiltValueNullFieldError.checkNotNull(id, r'Track', 'id'),
            cornerId: BuiltValueNullFieldError.checkNotNull(
                cornerId, r'Track', 'cornerId'),
            trackNo: BuiltValueNullFieldError.checkNotNull(
                trackNo, r'Track', 'trackNo'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Track', 'status'),
            operationalStatus: operationalStatus,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'currentVisit';
        _currentVisit?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Track', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
