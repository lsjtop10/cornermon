// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_track_id_visits_start_post_request_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TracksTrackIdVisitsStartPostRequestOneOf
    extends TracksTrackIdVisitsStartPostRequestOneOf {
  @override
  final String qrToken;

  factory _$TracksTrackIdVisitsStartPostRequestOneOf(
          [void Function(TracksTrackIdVisitsStartPostRequestOneOfBuilder)?
              updates]) =>
      (TracksTrackIdVisitsStartPostRequestOneOfBuilder()..update(updates))
          ._build();

  _$TracksTrackIdVisitsStartPostRequestOneOf._({required this.qrToken})
      : super._();
  @override
  TracksTrackIdVisitsStartPostRequestOneOf rebuild(
          void Function(TracksTrackIdVisitsStartPostRequestOneOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TracksTrackIdVisitsStartPostRequestOneOfBuilder toBuilder() =>
      TracksTrackIdVisitsStartPostRequestOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TracksTrackIdVisitsStartPostRequestOneOf &&
        qrToken == other.qrToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, qrToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'TracksTrackIdVisitsStartPostRequestOneOf')
          ..add('qrToken', qrToken))
        .toString();
  }
}

class TracksTrackIdVisitsStartPostRequestOneOfBuilder
    implements
        Builder<TracksTrackIdVisitsStartPostRequestOneOf,
            TracksTrackIdVisitsStartPostRequestOneOfBuilder> {
  _$TracksTrackIdVisitsStartPostRequestOneOf? _$v;

  String? _qrToken;
  String? get qrToken => _$this._qrToken;
  set qrToken(String? qrToken) => _$this._qrToken = qrToken;

  TracksTrackIdVisitsStartPostRequestOneOfBuilder() {
    TracksTrackIdVisitsStartPostRequestOneOf._defaults(this);
  }

  TracksTrackIdVisitsStartPostRequestOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _qrToken = $v.qrToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TracksTrackIdVisitsStartPostRequestOneOf other) {
    _$v = other as _$TracksTrackIdVisitsStartPostRequestOneOf;
  }

  @override
  void update(
      void Function(TracksTrackIdVisitsStartPostRequestOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TracksTrackIdVisitsStartPostRequestOneOf build() => _build();

  _$TracksTrackIdVisitsStartPostRequestOneOf _build() {
    final _$result = _$v ??
        _$TracksTrackIdVisitsStartPostRequestOneOf._(
          qrToken: BuiltValueNullFieldError.checkNotNull(
              qrToken, r'TracksTrackIdVisitsStartPostRequestOneOf', 'qrToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
