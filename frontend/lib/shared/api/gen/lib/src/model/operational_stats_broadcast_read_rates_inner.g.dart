// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operational_stats_broadcast_read_rates_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperationalStatsBroadcastReadRatesInner
    extends OperationalStatsBroadcastReadRatesInner {
  @override
  final String? messageId;
  @override
  final String? content;
  @override
  final int? readCount;
  @override
  final int? totalTracks;
  @override
  final double? readRate;

  factory _$OperationalStatsBroadcastReadRatesInner([
    void Function(OperationalStatsBroadcastReadRatesInnerBuilder)? updates,
  ]) => (OperationalStatsBroadcastReadRatesInnerBuilder()..update(updates))
      ._build();

  _$OperationalStatsBroadcastReadRatesInner._({
    this.messageId,
    this.content,
    this.readCount,
    this.totalTracks,
    this.readRate,
  }) : super._();
  @override
  OperationalStatsBroadcastReadRatesInner rebuild(
    void Function(OperationalStatsBroadcastReadRatesInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  OperationalStatsBroadcastReadRatesInnerBuilder toBuilder() =>
      OperationalStatsBroadcastReadRatesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperationalStatsBroadcastReadRatesInner &&
        messageId == other.messageId &&
        content == other.content &&
        readCount == other.readCount &&
        totalTracks == other.totalTracks &&
        readRate == other.readRate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, messageId.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, readCount.hashCode);
    _$hash = $jc(_$hash, totalTracks.hashCode);
    _$hash = $jc(_$hash, readRate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'OperationalStatsBroadcastReadRatesInner',
          )
          ..add('messageId', messageId)
          ..add('content', content)
          ..add('readCount', readCount)
          ..add('totalTracks', totalTracks)
          ..add('readRate', readRate))
        .toString();
  }
}

class OperationalStatsBroadcastReadRatesInnerBuilder
    implements
        Builder<
          OperationalStatsBroadcastReadRatesInner,
          OperationalStatsBroadcastReadRatesInnerBuilder
        > {
  _$OperationalStatsBroadcastReadRatesInner? _$v;

  String? _messageId;
  String? get messageId => _$this._messageId;
  set messageId(String? messageId) => _$this._messageId = messageId;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  int? _readCount;
  int? get readCount => _$this._readCount;
  set readCount(int? readCount) => _$this._readCount = readCount;

  int? _totalTracks;
  int? get totalTracks => _$this._totalTracks;
  set totalTracks(int? totalTracks) => _$this._totalTracks = totalTracks;

  double? _readRate;
  double? get readRate => _$this._readRate;
  set readRate(double? readRate) => _$this._readRate = readRate;

  OperationalStatsBroadcastReadRatesInnerBuilder() {
    OperationalStatsBroadcastReadRatesInner._defaults(this);
  }

  OperationalStatsBroadcastReadRatesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _messageId = $v.messageId;
      _content = $v.content;
      _readCount = $v.readCount;
      _totalTracks = $v.totalTracks;
      _readRate = $v.readRate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperationalStatsBroadcastReadRatesInner other) {
    _$v = other as _$OperationalStatsBroadcastReadRatesInner;
  }

  @override
  void update(
    void Function(OperationalStatsBroadcastReadRatesInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  OperationalStatsBroadcastReadRatesInner build() => _build();

  _$OperationalStatsBroadcastReadRatesInner _build() {
    final _$result =
        _$v ??
        _$OperationalStatsBroadcastReadRatesInner._(
          messageId: messageId,
          content: content,
          readCount: readCount,
          totalTracks: totalTracks,
          readRate: readRate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
