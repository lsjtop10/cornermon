// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_live_summary_get200_response_corners_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportsLiveSummaryGet200ResponseCornersInner
    extends ReportsLiveSummaryGet200ResponseCornersInner {
  @override
  final String? cornerId;
  @override
  final String? cornerName;
  @override
  final CornerOperationalStatus? status;
  @override
  final bool? isBottleneck;
  @override
  final int? completedVisitCount;

  factory _$ReportsLiveSummaryGet200ResponseCornersInner([
    void Function(ReportsLiveSummaryGet200ResponseCornersInnerBuilder)? updates,
  ]) => (ReportsLiveSummaryGet200ResponseCornersInnerBuilder()..update(updates))
      ._build();

  _$ReportsLiveSummaryGet200ResponseCornersInner._({
    this.cornerId,
    this.cornerName,
    this.status,
    this.isBottleneck,
    this.completedVisitCount,
  }) : super._();
  @override
  ReportsLiveSummaryGet200ResponseCornersInner rebuild(
    void Function(ReportsLiveSummaryGet200ResponseCornersInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ReportsLiveSummaryGet200ResponseCornersInnerBuilder toBuilder() =>
      ReportsLiveSummaryGet200ResponseCornersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportsLiveSummaryGet200ResponseCornersInner &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName &&
        status == other.status &&
        isBottleneck == other.isBottleneck &&
        completedVisitCount == other.completedVisitCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, isBottleneck.hashCode);
    _$hash = $jc(_$hash, completedVisitCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ReportsLiveSummaryGet200ResponseCornersInner',
          )
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName)
          ..add('status', status)
          ..add('isBottleneck', isBottleneck)
          ..add('completedVisitCount', completedVisitCount))
        .toString();
  }
}

class ReportsLiveSummaryGet200ResponseCornersInnerBuilder
    implements
        Builder<
          ReportsLiveSummaryGet200ResponseCornersInner,
          ReportsLiveSummaryGet200ResponseCornersInnerBuilder
        > {
  _$ReportsLiveSummaryGet200ResponseCornersInner? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  CornerOperationalStatus? _status;
  CornerOperationalStatus? get status => _$this._status;
  set status(CornerOperationalStatus? status) => _$this._status = status;

  bool? _isBottleneck;
  bool? get isBottleneck => _$this._isBottleneck;
  set isBottleneck(bool? isBottleneck) => _$this._isBottleneck = isBottleneck;

  int? _completedVisitCount;
  int? get completedVisitCount => _$this._completedVisitCount;
  set completedVisitCount(int? completedVisitCount) =>
      _$this._completedVisitCount = completedVisitCount;

  ReportsLiveSummaryGet200ResponseCornersInnerBuilder() {
    ReportsLiveSummaryGet200ResponseCornersInner._defaults(this);
  }

  ReportsLiveSummaryGet200ResponseCornersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _status = $v.status;
      _isBottleneck = $v.isBottleneck;
      _completedVisitCount = $v.completedVisitCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportsLiveSummaryGet200ResponseCornersInner other) {
    _$v = other as _$ReportsLiveSummaryGet200ResponseCornersInner;
  }

  @override
  void update(
    void Function(ReportsLiveSummaryGet200ResponseCornersInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ReportsLiveSummaryGet200ResponseCornersInner build() => _build();

  _$ReportsLiveSummaryGet200ResponseCornersInner _build() {
    final _$result =
        _$v ??
        _$ReportsLiveSummaryGet200ResponseCornersInner._(
          cornerId: cornerId,
          cornerName: cornerName,
          status: status,
          isBottleneck: isBottleneck,
          completedVisitCount: completedVisitCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
