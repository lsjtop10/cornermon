// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operational_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperationalStats extends OperationalStats {
  @override
  final int? pinLoginSuccessCount;
  @override
  final int? pinLoginFailureCount;
  @override
  final double? pinLoginFailureRate;
  @override
  final int? deviceRegistrationCount;
  @override
  final int? deviceApprovalCount;
  @override
  final int? deviceRejectionCount;
  @override
  final int? deviceRevocationCount;
  @override
  final BuiltList<OperationalStatsAdminActionCountsInner>? adminActionCounts;
  @override
  final BuiltList<OperationalStatsDirectMessageCountPerTrackInner>?
  directMessageCountPerTrack;
  @override
  final BuiltList<OperationalStatsBroadcastReadRatesInner>? broadcastReadRates;

  factory _$OperationalStats([
    void Function(OperationalStatsBuilder)? updates,
  ]) => (OperationalStatsBuilder()..update(updates))._build();

  _$OperationalStats._({
    this.pinLoginSuccessCount,
    this.pinLoginFailureCount,
    this.pinLoginFailureRate,
    this.deviceRegistrationCount,
    this.deviceApprovalCount,
    this.deviceRejectionCount,
    this.deviceRevocationCount,
    this.adminActionCounts,
    this.directMessageCountPerTrack,
    this.broadcastReadRates,
  }) : super._();
  @override
  OperationalStats rebuild(void Function(OperationalStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OperationalStatsBuilder toBuilder() =>
      OperationalStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperationalStats &&
        pinLoginSuccessCount == other.pinLoginSuccessCount &&
        pinLoginFailureCount == other.pinLoginFailureCount &&
        pinLoginFailureRate == other.pinLoginFailureRate &&
        deviceRegistrationCount == other.deviceRegistrationCount &&
        deviceApprovalCount == other.deviceApprovalCount &&
        deviceRejectionCount == other.deviceRejectionCount &&
        deviceRevocationCount == other.deviceRevocationCount &&
        adminActionCounts == other.adminActionCounts &&
        directMessageCountPerTrack == other.directMessageCountPerTrack &&
        broadcastReadRates == other.broadcastReadRates;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pinLoginSuccessCount.hashCode);
    _$hash = $jc(_$hash, pinLoginFailureCount.hashCode);
    _$hash = $jc(_$hash, pinLoginFailureRate.hashCode);
    _$hash = $jc(_$hash, deviceRegistrationCount.hashCode);
    _$hash = $jc(_$hash, deviceApprovalCount.hashCode);
    _$hash = $jc(_$hash, deviceRejectionCount.hashCode);
    _$hash = $jc(_$hash, deviceRevocationCount.hashCode);
    _$hash = $jc(_$hash, adminActionCounts.hashCode);
    _$hash = $jc(_$hash, directMessageCountPerTrack.hashCode);
    _$hash = $jc(_$hash, broadcastReadRates.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OperationalStats')
          ..add('pinLoginSuccessCount', pinLoginSuccessCount)
          ..add('pinLoginFailureCount', pinLoginFailureCount)
          ..add('pinLoginFailureRate', pinLoginFailureRate)
          ..add('deviceRegistrationCount', deviceRegistrationCount)
          ..add('deviceApprovalCount', deviceApprovalCount)
          ..add('deviceRejectionCount', deviceRejectionCount)
          ..add('deviceRevocationCount', deviceRevocationCount)
          ..add('adminActionCounts', adminActionCounts)
          ..add('directMessageCountPerTrack', directMessageCountPerTrack)
          ..add('broadcastReadRates', broadcastReadRates))
        .toString();
  }
}

class OperationalStatsBuilder
    implements Builder<OperationalStats, OperationalStatsBuilder> {
  _$OperationalStats? _$v;

  int? _pinLoginSuccessCount;
  int? get pinLoginSuccessCount => _$this._pinLoginSuccessCount;
  set pinLoginSuccessCount(int? pinLoginSuccessCount) =>
      _$this._pinLoginSuccessCount = pinLoginSuccessCount;

  int? _pinLoginFailureCount;
  int? get pinLoginFailureCount => _$this._pinLoginFailureCount;
  set pinLoginFailureCount(int? pinLoginFailureCount) =>
      _$this._pinLoginFailureCount = pinLoginFailureCount;

  double? _pinLoginFailureRate;
  double? get pinLoginFailureRate => _$this._pinLoginFailureRate;
  set pinLoginFailureRate(double? pinLoginFailureRate) =>
      _$this._pinLoginFailureRate = pinLoginFailureRate;

  int? _deviceRegistrationCount;
  int? get deviceRegistrationCount => _$this._deviceRegistrationCount;
  set deviceRegistrationCount(int? deviceRegistrationCount) =>
      _$this._deviceRegistrationCount = deviceRegistrationCount;

  int? _deviceApprovalCount;
  int? get deviceApprovalCount => _$this._deviceApprovalCount;
  set deviceApprovalCount(int? deviceApprovalCount) =>
      _$this._deviceApprovalCount = deviceApprovalCount;

  int? _deviceRejectionCount;
  int? get deviceRejectionCount => _$this._deviceRejectionCount;
  set deviceRejectionCount(int? deviceRejectionCount) =>
      _$this._deviceRejectionCount = deviceRejectionCount;

  int? _deviceRevocationCount;
  int? get deviceRevocationCount => _$this._deviceRevocationCount;
  set deviceRevocationCount(int? deviceRevocationCount) =>
      _$this._deviceRevocationCount = deviceRevocationCount;

  ListBuilder<OperationalStatsAdminActionCountsInner>? _adminActionCounts;
  ListBuilder<OperationalStatsAdminActionCountsInner> get adminActionCounts =>
      _$this._adminActionCounts ??=
          ListBuilder<OperationalStatsAdminActionCountsInner>();
  set adminActionCounts(
    ListBuilder<OperationalStatsAdminActionCountsInner>? adminActionCounts,
  ) => _$this._adminActionCounts = adminActionCounts;

  ListBuilder<OperationalStatsDirectMessageCountPerTrackInner>?
  _directMessageCountPerTrack;
  ListBuilder<OperationalStatsDirectMessageCountPerTrackInner>
  get directMessageCountPerTrack => _$this._directMessageCountPerTrack ??=
      ListBuilder<OperationalStatsDirectMessageCountPerTrackInner>();
  set directMessageCountPerTrack(
    ListBuilder<OperationalStatsDirectMessageCountPerTrackInner>?
    directMessageCountPerTrack,
  ) => _$this._directMessageCountPerTrack = directMessageCountPerTrack;

  ListBuilder<OperationalStatsBroadcastReadRatesInner>? _broadcastReadRates;
  ListBuilder<OperationalStatsBroadcastReadRatesInner> get broadcastReadRates =>
      _$this._broadcastReadRates ??=
          ListBuilder<OperationalStatsBroadcastReadRatesInner>();
  set broadcastReadRates(
    ListBuilder<OperationalStatsBroadcastReadRatesInner>? broadcastReadRates,
  ) => _$this._broadcastReadRates = broadcastReadRates;

  OperationalStatsBuilder() {
    OperationalStats._defaults(this);
  }

  OperationalStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pinLoginSuccessCount = $v.pinLoginSuccessCount;
      _pinLoginFailureCount = $v.pinLoginFailureCount;
      _pinLoginFailureRate = $v.pinLoginFailureRate;
      _deviceRegistrationCount = $v.deviceRegistrationCount;
      _deviceApprovalCount = $v.deviceApprovalCount;
      _deviceRejectionCount = $v.deviceRejectionCount;
      _deviceRevocationCount = $v.deviceRevocationCount;
      _adminActionCounts = $v.adminActionCounts?.toBuilder();
      _directMessageCountPerTrack = $v.directMessageCountPerTrack?.toBuilder();
      _broadcastReadRates = $v.broadcastReadRates?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperationalStats other) {
    _$v = other as _$OperationalStats;
  }

  @override
  void update(void Function(OperationalStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OperationalStats build() => _build();

  _$OperationalStats _build() {
    _$OperationalStats _$result;
    try {
      _$result =
          _$v ??
          _$OperationalStats._(
            pinLoginSuccessCount: pinLoginSuccessCount,
            pinLoginFailureCount: pinLoginFailureCount,
            pinLoginFailureRate: pinLoginFailureRate,
            deviceRegistrationCount: deviceRegistrationCount,
            deviceApprovalCount: deviceApprovalCount,
            deviceRejectionCount: deviceRejectionCount,
            deviceRevocationCount: deviceRevocationCount,
            adminActionCounts: _adminActionCounts?.build(),
            directMessageCountPerTrack: _directMessageCountPerTrack?.build(),
            broadcastReadRates: _broadcastReadRates?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'adminActionCounts';
        _adminActionCounts?.build();
        _$failedField = 'directMessageCountPerTrack';
        _directMessageCountPerTrack?.build();
        _$failedField = 'broadcastReadRates';
        _broadcastReadRates?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'OperationalStats',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
