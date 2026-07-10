// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camps_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CampsIdPatchRequest extends CampsIdPatchRequest {
  @override
  final String? name;
  @override
  final DateTime? startAt;
  @override
  final DateTime? endAt;
  @override
  final int? bottleneckMinSamples;
  @override
  final int? bottleneckRatioPct;

  factory _$CampsIdPatchRequest(
          [void Function(CampsIdPatchRequestBuilder)? updates]) =>
      (CampsIdPatchRequestBuilder()..update(updates))._build();

  _$CampsIdPatchRequest._(
      {this.name,
      this.startAt,
      this.endAt,
      this.bottleneckMinSamples,
      this.bottleneckRatioPct})
      : super._();
  @override
  CampsIdPatchRequest rebuild(
          void Function(CampsIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CampsIdPatchRequestBuilder toBuilder() =>
      CampsIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CampsIdPatchRequest &&
        name == other.name &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        bottleneckMinSamples == other.bottleneckMinSamples &&
        bottleneckRatioPct == other.bottleneckRatioPct;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, bottleneckMinSamples.hashCode);
    _$hash = $jc(_$hash, bottleneckRatioPct.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CampsIdPatchRequest')
          ..add('name', name)
          ..add('startAt', startAt)
          ..add('endAt', endAt)
          ..add('bottleneckMinSamples', bottleneckMinSamples)
          ..add('bottleneckRatioPct', bottleneckRatioPct))
        .toString();
  }
}

class CampsIdPatchRequestBuilder
    implements Builder<CampsIdPatchRequest, CampsIdPatchRequestBuilder> {
  _$CampsIdPatchRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  int? _bottleneckMinSamples;
  int? get bottleneckMinSamples => _$this._bottleneckMinSamples;
  set bottleneckMinSamples(int? bottleneckMinSamples) =>
      _$this._bottleneckMinSamples = bottleneckMinSamples;

  int? _bottleneckRatioPct;
  int? get bottleneckRatioPct => _$this._bottleneckRatioPct;
  set bottleneckRatioPct(int? bottleneckRatioPct) =>
      _$this._bottleneckRatioPct = bottleneckRatioPct;

  CampsIdPatchRequestBuilder() {
    CampsIdPatchRequest._defaults(this);
  }

  CampsIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _startAt = $v.startAt;
      _endAt = $v.endAt;
      _bottleneckMinSamples = $v.bottleneckMinSamples;
      _bottleneckRatioPct = $v.bottleneckRatioPct;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CampsIdPatchRequest other) {
    _$v = other as _$CampsIdPatchRequest;
  }

  @override
  void update(void Function(CampsIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CampsIdPatchRequest build() => _build();

  _$CampsIdPatchRequest _build() {
    final _$result = _$v ??
        _$CampsIdPatchRequest._(
          name: name,
          startAt: startAt,
          endAt: endAt,
          bottleneckMinSamples: bottleneckMinSamples,
          bottleneckRatioPct: bottleneckRatioPct,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
