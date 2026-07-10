// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_progress.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornerProgress extends CornerProgress {
  @override
  final String cornerId;
  @override
  final String? cornerName;
  @override
  final VisitStatusPerCorner status;

  factory _$CornerProgress([void Function(CornerProgressBuilder)? updates]) =>
      (CornerProgressBuilder()..update(updates))._build();

  _$CornerProgress._({
    required this.cornerId,
    this.cornerName,
    required this.status,
  }) : super._();
  @override
  CornerProgress rebuild(void Function(CornerProgressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerProgressBuilder toBuilder() => CornerProgressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerProgress &&
        cornerId == other.cornerId &&
        cornerName == other.cornerName &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerProgress')
          ..add('cornerId', cornerId)
          ..add('cornerName', cornerName)
          ..add('status', status))
        .toString();
  }
}

class CornerProgressBuilder
    implements Builder<CornerProgress, CornerProgressBuilder> {
  _$CornerProgress? _$v;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  VisitStatusPerCorner? _status;
  VisitStatusPerCorner? get status => _$this._status;
  set status(VisitStatusPerCorner? status) => _$this._status = status;

  CornerProgressBuilder() {
    CornerProgress._defaults(this);
  }

  CornerProgressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerId = $v.cornerId;
      _cornerName = $v.cornerName;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerProgress other) {
    _$v = other as _$CornerProgress;
  }

  @override
  void update(void Function(CornerProgressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerProgress build() => _build();

  _$CornerProgress _build() {
    final _$result =
        _$v ??
        _$CornerProgress._(
          cornerId: BuiltValueNullFieldError.checkNotNull(
            cornerId,
            r'CornerProgress',
            'cornerId',
          ),
          cornerName: cornerName,
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'CornerProgress',
            'status',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
