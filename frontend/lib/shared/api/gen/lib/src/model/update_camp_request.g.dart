// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'update_camp_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateCampRequest extends UpdateCampRequest {
  @override
  final int? bottleneckMinSamples;
  @override
  final int? bottleneckRatioPct;
  @override
  final DateTime? endAt;
  @override
  final String? name;
  @override
  final DateTime? startAt;

  factory _$UpdateCampRequest(
          [void Function(UpdateCampRequestBuilder)? updates]) =>
      (UpdateCampRequestBuilder()..update(updates))._build();

  _$UpdateCampRequest._(
      {this.bottleneckMinSamples,
      this.bottleneckRatioPct,
      this.endAt,
      this.name,
      this.startAt})
      : super._();
  @override
  UpdateCampRequest rebuild(void Function(UpdateCampRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateCampRequestBuilder toBuilder() =>
      UpdateCampRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateCampRequest &&
        bottleneckMinSamples == other.bottleneckMinSamples &&
        bottleneckRatioPct == other.bottleneckRatioPct &&
        endAt == other.endAt &&
        name == other.name &&
        startAt == other.startAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bottleneckMinSamples.hashCode);
    _$hash = $jc(_$hash, bottleneckRatioPct.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateCampRequest')
          ..add('bottleneckMinSamples', bottleneckMinSamples)
          ..add('bottleneckRatioPct', bottleneckRatioPct)
          ..add('endAt', endAt)
          ..add('name', name)
          ..add('startAt', startAt))
        .toString();
  }
}

class UpdateCampRequestBuilder
    implements Builder<UpdateCampRequest, UpdateCampRequestBuilder> {
  _$UpdateCampRequest? _$v;

  int? _bottleneckMinSamples;
  int? get bottleneckMinSamples => _$this._bottleneckMinSamples;
  set bottleneckMinSamples(int? bottleneckMinSamples) =>
      _$this._bottleneckMinSamples = bottleneckMinSamples;

  int? _bottleneckRatioPct;
  int? get bottleneckRatioPct => _$this._bottleneckRatioPct;
  set bottleneckRatioPct(int? bottleneckRatioPct) =>
      _$this._bottleneckRatioPct = bottleneckRatioPct;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  UpdateCampRequestBuilder() {
    UpdateCampRequest._defaults(this);
  }

  UpdateCampRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bottleneckMinSamples = $v.bottleneckMinSamples;
      _bottleneckRatioPct = $v.bottleneckRatioPct;
      _endAt = $v.endAt;
      _name = $v.name;
      _startAt = $v.startAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateCampRequest other) {
    _$v = other as _$UpdateCampRequest;
  }

  @override
  void update(void Function(UpdateCampRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateCampRequest build() => _build();

  _$UpdateCampRequest _build() {
    final _$result = _$v ??
        _$UpdateCampRequest._(
          bottleneckMinSamples: bottleneckMinSamples,
          bottleneckRatioPct: bottleneckRatioPct,
          endAt: endAt,
          name: name,
          startAt: startAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
