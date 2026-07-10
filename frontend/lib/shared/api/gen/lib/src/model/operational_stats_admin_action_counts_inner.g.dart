// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operational_stats_admin_action_counts_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperationalStatsAdminActionCountsInner
    extends OperationalStatsAdminActionCountsInner {
  @override
  final String? adminId;
  @override
  final int? actionCount;

  factory _$OperationalStatsAdminActionCountsInner([
    void Function(OperationalStatsAdminActionCountsInnerBuilder)? updates,
  ]) => (OperationalStatsAdminActionCountsInnerBuilder()..update(updates))
      ._build();

  _$OperationalStatsAdminActionCountsInner._({this.adminId, this.actionCount})
    : super._();
  @override
  OperationalStatsAdminActionCountsInner rebuild(
    void Function(OperationalStatsAdminActionCountsInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  OperationalStatsAdminActionCountsInnerBuilder toBuilder() =>
      OperationalStatsAdminActionCountsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperationalStatsAdminActionCountsInner &&
        adminId == other.adminId &&
        actionCount == other.actionCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, adminId.hashCode);
    _$hash = $jc(_$hash, actionCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'OperationalStatsAdminActionCountsInner',
          )
          ..add('adminId', adminId)
          ..add('actionCount', actionCount))
        .toString();
  }
}

class OperationalStatsAdminActionCountsInnerBuilder
    implements
        Builder<
          OperationalStatsAdminActionCountsInner,
          OperationalStatsAdminActionCountsInnerBuilder
        > {
  _$OperationalStatsAdminActionCountsInner? _$v;

  String? _adminId;
  String? get adminId => _$this._adminId;
  set adminId(String? adminId) => _$this._adminId = adminId;

  int? _actionCount;
  int? get actionCount => _$this._actionCount;
  set actionCount(int? actionCount) => _$this._actionCount = actionCount;

  OperationalStatsAdminActionCountsInnerBuilder() {
    OperationalStatsAdminActionCountsInner._defaults(this);
  }

  OperationalStatsAdminActionCountsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _adminId = $v.adminId;
      _actionCount = $v.actionCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperationalStatsAdminActionCountsInner other) {
    _$v = other as _$OperationalStatsAdminActionCountsInner;
  }

  @override
  void update(
    void Function(OperationalStatsAdminActionCountsInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  OperationalStatsAdminActionCountsInner build() => _build();

  _$OperationalStatsAdminActionCountsInner _build() {
    final _$result =
        _$v ??
        _$OperationalStatsAdminActionCountsInner._(
          adminId: adminId,
          actionCount: actionCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
