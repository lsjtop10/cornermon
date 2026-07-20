// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'replace_track_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReplaceTrackRequest extends ReplaceTrackRequest {
  @override
  final String? newCornerId;

  factory _$ReplaceTrackRequest(
          [void Function(ReplaceTrackRequestBuilder)? updates]) =>
      (ReplaceTrackRequestBuilder()..update(updates))._build();

  _$ReplaceTrackRequest._({this.newCornerId}) : super._();
  @override
  ReplaceTrackRequest rebuild(
          void Function(ReplaceTrackRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReplaceTrackRequestBuilder toBuilder() =>
      ReplaceTrackRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReplaceTrackRequest && newCornerId == other.newCornerId;
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
    return (newBuiltValueToStringHelper(r'ReplaceTrackRequest')
          ..add('newCornerId', newCornerId))
        .toString();
  }
}

class ReplaceTrackRequestBuilder
    implements Builder<ReplaceTrackRequest, ReplaceTrackRequestBuilder> {
  _$ReplaceTrackRequest? _$v;

  String? _newCornerId;
  String? get newCornerId => _$this._newCornerId;
  set newCornerId(String? newCornerId) => _$this._newCornerId = newCornerId;

  ReplaceTrackRequestBuilder() {
    ReplaceTrackRequest._defaults(this);
  }

  ReplaceTrackRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newCornerId = $v.newCornerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReplaceTrackRequest other) {
    _$v = other as _$ReplaceTrackRequest;
  }

  @override
  void update(void Function(ReplaceTrackRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReplaceTrackRequest build() => _build();

  _$ReplaceTrackRequest _build() {
    final _$result = _$v ??
        _$ReplaceTrackRequest._(
          newCornerId: newCornerId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
