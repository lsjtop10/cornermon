// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'corner_matric_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CornerMatricResponse extends CornerMatricResponse {
  @override
  final int? avgDurationSeconds;
  @override
  final int? sampleCount;

  factory _$CornerMatricResponse(
          [void Function(CornerMatricResponseBuilder)? updates]) =>
      (CornerMatricResponseBuilder()..update(updates))._build();

  _$CornerMatricResponse._({this.avgDurationSeconds, this.sampleCount})
      : super._();
  @override
  CornerMatricResponse rebuild(
          void Function(CornerMatricResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CornerMatricResponseBuilder toBuilder() =>
      CornerMatricResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CornerMatricResponse &&
        avgDurationSeconds == other.avgDurationSeconds &&
        sampleCount == other.sampleCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgDurationSeconds.hashCode);
    _$hash = $jc(_$hash, sampleCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CornerMatricResponse')
          ..add('avgDurationSeconds', avgDurationSeconds)
          ..add('sampleCount', sampleCount))
        .toString();
  }
}

class CornerMatricResponseBuilder
    implements Builder<CornerMatricResponse, CornerMatricResponseBuilder> {
  _$CornerMatricResponse? _$v;

  int? _avgDurationSeconds;
  int? get avgDurationSeconds => _$this._avgDurationSeconds;
  set avgDurationSeconds(int? avgDurationSeconds) =>
      _$this._avgDurationSeconds = avgDurationSeconds;

  int? _sampleCount;
  int? get sampleCount => _$this._sampleCount;
  set sampleCount(int? sampleCount) => _$this._sampleCount = sampleCount;

  CornerMatricResponseBuilder() {
    CornerMatricResponse._defaults(this);
  }

  CornerMatricResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgDurationSeconds = $v.avgDurationSeconds;
      _sampleCount = $v.sampleCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CornerMatricResponse other) {
    _$v = other as _$CornerMatricResponse;
  }

  @override
  void update(void Function(CornerMatricResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CornerMatricResponse build() => _build();

  _$CornerMatricResponse _build() {
    final _$result = _$v ??
        _$CornerMatricResponse._(
          avgDurationSeconds: avgDurationSeconds,
          sampleCount: sampleCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
