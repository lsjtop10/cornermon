// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operational_stats_direct_message_count_per_track_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperationalStatsDirectMessageCountPerTrackInner
    extends OperationalStatsDirectMessageCountPerTrackInner {
  @override
  final String? trackId;
  @override
  final int? messageCount;

  factory _$OperationalStatsDirectMessageCountPerTrackInner(
          [void Function(
                  OperationalStatsDirectMessageCountPerTrackInnerBuilder)?
              updates]) =>
      (OperationalStatsDirectMessageCountPerTrackInnerBuilder()
            ..update(updates))
          ._build();

  _$OperationalStatsDirectMessageCountPerTrackInner._(
      {this.trackId, this.messageCount})
      : super._();
  @override
  OperationalStatsDirectMessageCountPerTrackInner rebuild(
          void Function(OperationalStatsDirectMessageCountPerTrackInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OperationalStatsDirectMessageCountPerTrackInnerBuilder toBuilder() =>
      OperationalStatsDirectMessageCountPerTrackInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperationalStatsDirectMessageCountPerTrackInner &&
        trackId == other.trackId &&
        messageCount == other.messageCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, messageCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'OperationalStatsDirectMessageCountPerTrackInner')
          ..add('trackId', trackId)
          ..add('messageCount', messageCount))
        .toString();
  }
}

class OperationalStatsDirectMessageCountPerTrackInnerBuilder
    implements
        Builder<OperationalStatsDirectMessageCountPerTrackInner,
            OperationalStatsDirectMessageCountPerTrackInnerBuilder> {
  _$OperationalStatsDirectMessageCountPerTrackInner? _$v;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  int? _messageCount;
  int? get messageCount => _$this._messageCount;
  set messageCount(int? messageCount) => _$this._messageCount = messageCount;

  OperationalStatsDirectMessageCountPerTrackInnerBuilder() {
    OperationalStatsDirectMessageCountPerTrackInner._defaults(this);
  }

  OperationalStatsDirectMessageCountPerTrackInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trackId = $v.trackId;
      _messageCount = $v.messageCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperationalStatsDirectMessageCountPerTrackInner other) {
    _$v = other as _$OperationalStatsDirectMessageCountPerTrackInner;
  }

  @override
  void update(
      void Function(OperationalStatsDirectMessageCountPerTrackInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  OperationalStatsDirectMessageCountPerTrackInner build() => _build();

  _$OperationalStatsDirectMessageCountPerTrackInner _build() {
    final _$result = _$v ??
        _$OperationalStatsDirectMessageCountPerTrackInner._(
          trackId: trackId,
          messageCount: messageCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
