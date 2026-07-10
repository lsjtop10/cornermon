// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_live_summary_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportsLiveSummaryGet200Response
    extends ReportsLiveSummaryGet200Response {
  @override
  final int? totalGroups;
  @override
  final int? finishedGroups;
  @override
  final BuiltList<ReportsLiveSummaryGet200ResponseCornersInner>? corners;

  factory _$ReportsLiveSummaryGet200Response(
          [void Function(ReportsLiveSummaryGet200ResponseBuilder)? updates]) =>
      (ReportsLiveSummaryGet200ResponseBuilder()..update(updates))._build();

  _$ReportsLiveSummaryGet200Response._(
      {this.totalGroups, this.finishedGroups, this.corners})
      : super._();
  @override
  ReportsLiveSummaryGet200Response rebuild(
          void Function(ReportsLiveSummaryGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportsLiveSummaryGet200ResponseBuilder toBuilder() =>
      ReportsLiveSummaryGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportsLiveSummaryGet200Response &&
        totalGroups == other.totalGroups &&
        finishedGroups == other.finishedGroups &&
        corners == other.corners;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalGroups.hashCode);
    _$hash = $jc(_$hash, finishedGroups.hashCode);
    _$hash = $jc(_$hash, corners.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportsLiveSummaryGet200Response')
          ..add('totalGroups', totalGroups)
          ..add('finishedGroups', finishedGroups)
          ..add('corners', corners))
        .toString();
  }
}

class ReportsLiveSummaryGet200ResponseBuilder
    implements
        Builder<ReportsLiveSummaryGet200Response,
            ReportsLiveSummaryGet200ResponseBuilder> {
  _$ReportsLiveSummaryGet200Response? _$v;

  int? _totalGroups;
  int? get totalGroups => _$this._totalGroups;
  set totalGroups(int? totalGroups) => _$this._totalGroups = totalGroups;

  int? _finishedGroups;
  int? get finishedGroups => _$this._finishedGroups;
  set finishedGroups(int? finishedGroups) =>
      _$this._finishedGroups = finishedGroups;

  ListBuilder<ReportsLiveSummaryGet200ResponseCornersInner>? _corners;
  ListBuilder<ReportsLiveSummaryGet200ResponseCornersInner> get corners =>
      _$this._corners ??=
          ListBuilder<ReportsLiveSummaryGet200ResponseCornersInner>();
  set corners(
          ListBuilder<ReportsLiveSummaryGet200ResponseCornersInner>? corners) =>
      _$this._corners = corners;

  ReportsLiveSummaryGet200ResponseBuilder() {
    ReportsLiveSummaryGet200Response._defaults(this);
  }

  ReportsLiveSummaryGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalGroups = $v.totalGroups;
      _finishedGroups = $v.finishedGroups;
      _corners = $v.corners?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportsLiveSummaryGet200Response other) {
    _$v = other as _$ReportsLiveSummaryGet200Response;
  }

  @override
  void update(void Function(ReportsLiveSummaryGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportsLiveSummaryGet200Response build() => _build();

  _$ReportsLiveSummaryGet200Response _build() {
    _$ReportsLiveSummaryGet200Response _$result;
    try {
      _$result = _$v ??
          _$ReportsLiveSummaryGet200Response._(
            totalGroups: totalGroups,
            finishedGroups: finishedGroups,
            corners: _corners?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'corners';
        _corners?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReportsLiveSummaryGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
