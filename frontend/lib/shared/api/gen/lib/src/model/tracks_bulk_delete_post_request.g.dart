// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_bulk_delete_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TracksBulkDeletePostRequest extends TracksBulkDeletePostRequest {
  @override
  final BuiltList<String> trackIds;

  factory _$TracksBulkDeletePostRequest(
          [void Function(TracksBulkDeletePostRequestBuilder)? updates]) =>
      (TracksBulkDeletePostRequestBuilder()..update(updates))._build();

  _$TracksBulkDeletePostRequest._({required this.trackIds}) : super._();
  @override
  TracksBulkDeletePostRequest rebuild(
          void Function(TracksBulkDeletePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TracksBulkDeletePostRequestBuilder toBuilder() =>
      TracksBulkDeletePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TracksBulkDeletePostRequest && trackIds == other.trackIds;
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
    return (newBuiltValueToStringHelper(r'TracksBulkDeletePostRequest')
          ..add('trackIds', trackIds))
        .toString();
  }
}

class TracksBulkDeletePostRequestBuilder
    implements
        Builder<TracksBulkDeletePostRequest,
            TracksBulkDeletePostRequestBuilder> {
  _$TracksBulkDeletePostRequest? _$v;

  ListBuilder<String>? _trackIds;
  ListBuilder<String> get trackIds =>
      _$this._trackIds ??= ListBuilder<String>();
  set trackIds(ListBuilder<String>? trackIds) => _$this._trackIds = trackIds;

  TracksBulkDeletePostRequestBuilder() {
    TracksBulkDeletePostRequest._defaults(this);
  }

  TracksBulkDeletePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trackIds = $v.trackIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TracksBulkDeletePostRequest other) {
    _$v = other as _$TracksBulkDeletePostRequest;
  }

  @override
  void update(void Function(TracksBulkDeletePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TracksBulkDeletePostRequest build() => _build();

  _$TracksBulkDeletePostRequest _build() {
    _$TracksBulkDeletePostRequest _$result;
    try {
      _$result = _$v ??
          _$TracksBulkDeletePostRequest._(
            trackIds: trackIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'trackIds';
        trackIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TracksBulkDeletePostRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
