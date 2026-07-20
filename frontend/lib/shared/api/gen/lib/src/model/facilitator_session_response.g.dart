// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'facilitator_session_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FacilitatorSessionResponse extends FacilitatorSessionResponse {
  @override
  final DateTime? createdAt;
  @override
  final String? id;
  @override
  final String? trackId;

  factory _$FacilitatorSessionResponse(
          [void Function(FacilitatorSessionResponseBuilder)? updates]) =>
      (FacilitatorSessionResponseBuilder()..update(updates))._build();

  _$FacilitatorSessionResponse._({this.createdAt, this.id, this.trackId})
      : super._();
  @override
  FacilitatorSessionResponse rebuild(
          void Function(FacilitatorSessionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FacilitatorSessionResponseBuilder toBuilder() =>
      FacilitatorSessionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FacilitatorSessionResponse &&
        createdAt == other.createdAt &&
        id == other.id &&
        trackId == other.trackId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FacilitatorSessionResponse')
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('trackId', trackId))
        .toString();
  }
}

class FacilitatorSessionResponseBuilder
    implements
        Builder<FacilitatorSessionResponse, FacilitatorSessionResponseBuilder> {
  _$FacilitatorSessionResponse? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  FacilitatorSessionResponseBuilder() {
    FacilitatorSessionResponse._defaults(this);
  }

  FacilitatorSessionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _id = $v.id;
      _trackId = $v.trackId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FacilitatorSessionResponse other) {
    _$v = other as _$FacilitatorSessionResponse;
  }

  @override
  void update(void Function(FacilitatorSessionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FacilitatorSessionResponse build() => _build();

  _$FacilitatorSessionResponse _build() {
    final _$result = _$v ??
        _$FacilitatorSessionResponse._(
          createdAt: createdAt,
          id: id,
          trackId: trackId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
