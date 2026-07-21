// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tracks_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateTracksRequest extends CreateTracksRequest {
  @override
  final String? campId;
  @override
  final String? cornerId;
  @override
  final int? count;

  factory _$CreateTracksRequest(
          [void Function(CreateTracksRequestBuilder)? updates]) =>
      (CreateTracksRequestBuilder()..update(updates))._build();

  _$CreateTracksRequest._({this.campId, this.cornerId, this.count}) : super._();
  @override
  CreateTracksRequest rebuild(
          void Function(CreateTracksRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateTracksRequestBuilder toBuilder() =>
      CreateTracksRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateTracksRequest &&
        campId == other.campId &&
        cornerId == other.cornerId &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, campId.hashCode);
    _$hash = $jc(_$hash, cornerId.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateTracksRequest')
          ..add('campId', campId)
          ..add('cornerId', cornerId)
          ..add('count', count))
        .toString();
  }
}

class CreateTracksRequestBuilder
    implements Builder<CreateTracksRequest, CreateTracksRequestBuilder> {
  _$CreateTracksRequest? _$v;

  String? _campId;
  String? get campId => _$this._campId;
  set campId(String? campId) => _$this._campId = campId;

  String? _cornerId;
  String? get cornerId => _$this._cornerId;
  set cornerId(String? cornerId) => _$this._cornerId = cornerId;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  CreateTracksRequestBuilder() {
    CreateTracksRequest._defaults(this);
  }

  CreateTracksRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _campId = $v.campId;
      _cornerId = $v.cornerId;
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateTracksRequest other) {
    _$v = other as _$CreateTracksRequest;
  }

  @override
  void update(void Function(CreateTracksRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateTracksRequest build() => _build();

  _$CreateTracksRequest _build() {
    final _$result = _$v ??
        _$CreateTracksRequest._(
          campId: campId,
          cornerId: cornerId,
          count: count,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
