// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_id_replace_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TracksIdReplacePostRequest extends TracksIdReplacePostRequest {
  @override
  final String newCornerId;

  factory _$TracksIdReplacePostRequest(
          [void Function(TracksIdReplacePostRequestBuilder)? updates]) =>
      (TracksIdReplacePostRequestBuilder()..update(updates))._build();

  _$TracksIdReplacePostRequest._({required this.newCornerId}) : super._();
  @override
  TracksIdReplacePostRequest rebuild(
          void Function(TracksIdReplacePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TracksIdReplacePostRequestBuilder toBuilder() =>
      TracksIdReplacePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TracksIdReplacePostRequest &&
        newCornerId == other.newCornerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newCornerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TracksIdReplacePostRequest')
          ..add('newCornerId', newCornerId))
        .toString();
  }
}

class TracksIdReplacePostRequestBuilder
    implements
        Builder<TracksIdReplacePostRequest, TracksIdReplacePostRequestBuilder> {
  _$TracksIdReplacePostRequest? _$v;

  String? _newCornerId;
  String? get newCornerId => _$this._newCornerId;
  set newCornerId(String? newCornerId) => _$this._newCornerId = newCornerId;

  TracksIdReplacePostRequestBuilder() {
    TracksIdReplacePostRequest._defaults(this);
  }

  TracksIdReplacePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newCornerId = $v.newCornerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TracksIdReplacePostRequest other) {
    _$v = other as _$TracksIdReplacePostRequest;
  }

  @override
  void update(void Function(TracksIdReplacePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TracksIdReplacePostRequest build() => _build();

  _$TracksIdReplacePostRequest _build() {
    final _$result = _$v ??
        _$TracksIdReplacePostRequest._(
          newCornerId: BuiltValueNullFieldError.checkNotNull(
              newCornerId, r'TracksIdReplacePostRequest', 'newCornerId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
