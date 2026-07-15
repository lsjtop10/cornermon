// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_delete_tracks_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BulkDeleteTracksRequest extends BulkDeleteTracksRequest {
  @override
  final BuiltList<String>? trackIds;

  factory _$BulkDeleteTracksRequest(
          [void Function(BulkDeleteTracksRequestBuilder)? updates]) =>
      (BulkDeleteTracksRequestBuilder()..update(updates))._build();

  _$BulkDeleteTracksRequest._({this.trackIds}) : super._();
  @override
  BulkDeleteTracksRequest rebuild(
          void Function(BulkDeleteTracksRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BulkDeleteTracksRequestBuilder toBuilder() =>
      BulkDeleteTracksRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BulkDeleteTracksRequest && trackIds == other.trackIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trackIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BulkDeleteTracksRequest')
          ..add('trackIds', trackIds))
        .toString();
  }
}

class BulkDeleteTracksRequestBuilder
    implements
        Builder<BulkDeleteTracksRequest, BulkDeleteTracksRequestBuilder> {
  _$BulkDeleteTracksRequest? _$v;

  ListBuilder<String>? _trackIds;
  ListBuilder<String> get trackIds =>
      _$this._trackIds ??= ListBuilder<String>();
  set trackIds(ListBuilder<String>? trackIds) => _$this._trackIds = trackIds;

  BulkDeleteTracksRequestBuilder() {
    BulkDeleteTracksRequest._defaults(this);
  }

  BulkDeleteTracksRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trackIds = $v.trackIds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BulkDeleteTracksRequest other) {
    _$v = other as _$BulkDeleteTracksRequest;
  }

  @override
  void update(void Function(BulkDeleteTracksRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BulkDeleteTracksRequest build() => _build();

  _$BulkDeleteTracksRequest _build() {
    _$BulkDeleteTracksRequest _$result;
    try {
      _$result = _$v ??
          _$BulkDeleteTracksRequest._(
            trackIds: _trackIds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'trackIds';
        _trackIds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BulkDeleteTracksRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
