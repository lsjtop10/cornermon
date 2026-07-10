// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corners_post_request_corners_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornersPostRequestCornersInner extends CornersPostRequestCornersInner {
  @override
  final String name;
  @override
  final int? targetMinutes;
  @override
  final int? initialTrackCount;

  factory _$CornersPostRequestCornersInner([
    void Function(CornersPostRequestCornersInnerBuilder)? updates,
  ]) => (CornersPostRequestCornersInnerBuilder()..update(updates))._build();

  _$CornersPostRequestCornersInner._({
    required this.name,
    this.targetMinutes,
    this.initialTrackCount,
  }) : super._();
  @override
  CornersPostRequestCornersInner rebuild(
    void Function(CornersPostRequestCornersInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CornersPostRequestCornersInnerBuilder toBuilder() =>
      CornersPostRequestCornersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornersPostRequestCornersInner &&
        name == other.name &&
        targetMinutes == other.targetMinutes &&
        initialTrackCount == other.initialTrackCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, targetMinutes.hashCode);
    _$hash = $jc(_$hash, initialTrackCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornersPostRequestCornersInner')
          ..add('name', name)
          ..add('targetMinutes', targetMinutes)
          ..add('initialTrackCount', initialTrackCount))
        .toString();
  }
}

class CornersPostRequestCornersInnerBuilder
    implements
        Builder<
          CornersPostRequestCornersInner,
          CornersPostRequestCornersInnerBuilder
        > {
  _$CornersPostRequestCornersInner? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _targetMinutes;
  int? get targetMinutes => _$this._targetMinutes;
  set targetMinutes(int? targetMinutes) =>
      _$this._targetMinutes = targetMinutes;

  int? _initialTrackCount;
  int? get initialTrackCount => _$this._initialTrackCount;
  set initialTrackCount(int? initialTrackCount) =>
      _$this._initialTrackCount = initialTrackCount;

  CornersPostRequestCornersInnerBuilder() {
    CornersPostRequestCornersInner._defaults(this);
  }

  CornersPostRequestCornersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _targetMinutes = $v.targetMinutes;
      _initialTrackCount = $v.initialTrackCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornersPostRequestCornersInner other) {
    _$v = other as _$CornersPostRequestCornersInner;
  }

  @override
  void update(void Function(CornersPostRequestCornersInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornersPostRequestCornersInner build() => _build();

  _$CornersPostRequestCornersInner _build() {
    final _$result =
        _$v ??
        _$CornersPostRequestCornersInner._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CornersPostRequestCornersInner',
            'name',
          ),
          targetMinutes: targetMinutes,
          initialTrackCount: initialTrackCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
