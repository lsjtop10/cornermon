// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operational_stats_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperationalStatsResponse extends OperationalStatsResponse {
  @override
  final BuiltList<AdminOperationCountResponse>? adminOperationCounts;
  @override
  final BuiltList<AnnouncementReadStatResponse>? announcementReadStats;
  @override
  final int? deviceApprovedCount;
  @override
  final int? deviceRejectedCount;
  @override
  final int? deviceRequestCount;
  @override
  final int? deviceRevokedCount;
  @override
  final int? pinLoginFailureCount;
  @override
  final int? pinLoginSuccessCount;
  @override
  final BuiltList<TrackMessageCountResponse>? trackDirectMessageCounts;

  factory _$OperationalStatsResponse(
          [void Function(OperationalStatsResponseBuilder)? updates]) =>
      (OperationalStatsResponseBuilder()..update(updates))._build();

  _$OperationalStatsResponse._(
      {this.adminOperationCounts,
      this.announcementReadStats,
      this.deviceApprovedCount,
      this.deviceRejectedCount,
      this.deviceRequestCount,
      this.deviceRevokedCount,
      this.pinLoginFailureCount,
      this.pinLoginSuccessCount,
      this.trackDirectMessageCounts})
      : super._();
  @override
  OperationalStatsResponse rebuild(
          void Function(OperationalStatsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OperationalStatsResponseBuilder toBuilder() =>
      OperationalStatsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperationalStatsResponse &&
        adminOperationCounts == other.adminOperationCounts &&
        announcementReadStats == other.announcementReadStats &&
        deviceApprovedCount == other.deviceApprovedCount &&
        deviceRejectedCount == other.deviceRejectedCount &&
        deviceRequestCount == other.deviceRequestCount &&
        deviceRevokedCount == other.deviceRevokedCount &&
        pinLoginFailureCount == other.pinLoginFailureCount &&
        pinLoginSuccessCount == other.pinLoginSuccessCount &&
        trackDirectMessageCounts == other.trackDirectMessageCounts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, adminOperationCounts.hashCode);
    _$hash = $jc(_$hash, announcementReadStats.hashCode);
    _$hash = $jc(_$hash, deviceApprovedCount.hashCode);
    _$hash = $jc(_$hash, deviceRejectedCount.hashCode);
    _$hash = $jc(_$hash, deviceRequestCount.hashCode);
    _$hash = $jc(_$hash, deviceRevokedCount.hashCode);
    _$hash = $jc(_$hash, pinLoginFailureCount.hashCode);
    _$hash = $jc(_$hash, pinLoginSuccessCount.hashCode);
    _$hash = $jc(_$hash, trackDirectMessageCounts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OperationalStatsResponse')
          ..add('adminOperationCounts', adminOperationCounts)
          ..add('announcementReadStats', announcementReadStats)
          ..add('deviceApprovedCount', deviceApprovedCount)
          ..add('deviceRejectedCount', deviceRejectedCount)
          ..add('deviceRequestCount', deviceRequestCount)
          ..add('deviceRevokedCount', deviceRevokedCount)
          ..add('pinLoginFailureCount', pinLoginFailureCount)
          ..add('pinLoginSuccessCount', pinLoginSuccessCount)
          ..add('trackDirectMessageCounts', trackDirectMessageCounts))
        .toString();
  }
}

class OperationalStatsResponseBuilder
    implements
        Builder<OperationalStatsResponse, OperationalStatsResponseBuilder> {
  _$OperationalStatsResponse? _$v;

  ListBuilder<AdminOperationCountResponse>? _adminOperationCounts;
  ListBuilder<AdminOperationCountResponse> get adminOperationCounts =>
      _$this._adminOperationCounts ??=
          ListBuilder<AdminOperationCountResponse>();
  set adminOperationCounts(
          ListBuilder<AdminOperationCountResponse>? adminOperationCounts) =>
      _$this._adminOperationCounts = adminOperationCounts;

  ListBuilder<AnnouncementReadStatResponse>? _announcementReadStats;
  ListBuilder<AnnouncementReadStatResponse> get announcementReadStats =>
      _$this._announcementReadStats ??=
          ListBuilder<AnnouncementReadStatResponse>();
  set announcementReadStats(
          ListBuilder<AnnouncementReadStatResponse>? announcementReadStats) =>
      _$this._announcementReadStats = announcementReadStats;

  int? _deviceApprovedCount;
  int? get deviceApprovedCount => _$this._deviceApprovedCount;
  set deviceApprovedCount(int? deviceApprovedCount) =>
      _$this._deviceApprovedCount = deviceApprovedCount;

  int? _deviceRejectedCount;
  int? get deviceRejectedCount => _$this._deviceRejectedCount;
  set deviceRejectedCount(int? deviceRejectedCount) =>
      _$this._deviceRejectedCount = deviceRejectedCount;

  int? _deviceRequestCount;
  int? get deviceRequestCount => _$this._deviceRequestCount;
  set deviceRequestCount(int? deviceRequestCount) =>
      _$this._deviceRequestCount = deviceRequestCount;

  int? _deviceRevokedCount;
  int? get deviceRevokedCount => _$this._deviceRevokedCount;
  set deviceRevokedCount(int? deviceRevokedCount) =>
      _$this._deviceRevokedCount = deviceRevokedCount;

  int? _pinLoginFailureCount;
  int? get pinLoginFailureCount => _$this._pinLoginFailureCount;
  set pinLoginFailureCount(int? pinLoginFailureCount) =>
      _$this._pinLoginFailureCount = pinLoginFailureCount;

  int? _pinLoginSuccessCount;
  int? get pinLoginSuccessCount => _$this._pinLoginSuccessCount;
  set pinLoginSuccessCount(int? pinLoginSuccessCount) =>
      _$this._pinLoginSuccessCount = pinLoginSuccessCount;

  ListBuilder<TrackMessageCountResponse>? _trackDirectMessageCounts;
  ListBuilder<TrackMessageCountResponse> get trackDirectMessageCounts =>
      _$this._trackDirectMessageCounts ??=
          ListBuilder<TrackMessageCountResponse>();
  set trackDirectMessageCounts(
          ListBuilder<TrackMessageCountResponse>? trackDirectMessageCounts) =>
      _$this._trackDirectMessageCounts = trackDirectMessageCounts;

  OperationalStatsResponseBuilder() {
    OperationalStatsResponse._defaults(this);
  }

  OperationalStatsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _adminOperationCounts = $v.adminOperationCounts?.toBuilder();
      _announcementReadStats = $v.announcementReadStats?.toBuilder();
      _deviceApprovedCount = $v.deviceApprovedCount;
      _deviceRejectedCount = $v.deviceRejectedCount;
      _deviceRequestCount = $v.deviceRequestCount;
      _deviceRevokedCount = $v.deviceRevokedCount;
      _pinLoginFailureCount = $v.pinLoginFailureCount;
      _pinLoginSuccessCount = $v.pinLoginSuccessCount;
      _trackDirectMessageCounts = $v.trackDirectMessageCounts?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperationalStatsResponse other) {
    _$v = other as _$OperationalStatsResponse;
  }

  @override
  void update(void Function(OperationalStatsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OperationalStatsResponse build() => _build();

  _$OperationalStatsResponse _build() {
    _$OperationalStatsResponse _$result;
    try {
      _$result = _$v ??
          _$OperationalStatsResponse._(
            adminOperationCounts: _adminOperationCounts?.build(),
            announcementReadStats: _announcementReadStats?.build(),
            deviceApprovedCount: deviceApprovedCount,
            deviceRejectedCount: deviceRejectedCount,
            deviceRequestCount: deviceRequestCount,
            deviceRevokedCount: deviceRevokedCount,
            pinLoginFailureCount: pinLoginFailureCount,
            pinLoginSuccessCount: pinLoginSuccessCount,
            trackDirectMessageCounts: _trackDirectMessageCounts?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'adminOperationCounts';
        _adminOperationCounts?.build();
        _$failedField = 'announcementReadStats';
        _announcementReadStats?.build();

        _$failedField = 'trackDirectMessageCounts';
        _trackDirectMessageCounts?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OperationalStatsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
