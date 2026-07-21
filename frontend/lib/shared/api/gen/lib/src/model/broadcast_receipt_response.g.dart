// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_receipt_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BroadcastReceiptResponse extends BroadcastReceiptResponse {
  @override
  final String? cornerName;
  @override
  final bool? isRead;
  @override
  final DateTime? readAt;
  @override
  final String? trackId;
  @override
  final int? trackNo;

  factory _$BroadcastReceiptResponse(
          [void Function(BroadcastReceiptResponseBuilder)? updates]) =>
      (BroadcastReceiptResponseBuilder()..update(updates))._build();

  _$BroadcastReceiptResponse._(
      {this.cornerName, this.isRead, this.readAt, this.trackId, this.trackNo})
      : super._();
  @override
  BroadcastReceiptResponse rebuild(
          void Function(BroadcastReceiptResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BroadcastReceiptResponseBuilder toBuilder() =>
      BroadcastReceiptResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BroadcastReceiptResponse &&
        cornerName == other.cornerName &&
        isRead == other.isRead &&
        readAt == other.readAt &&
        trackId == other.trackId &&
        trackNo == other.trackNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BroadcastReceiptResponse')
          ..add('cornerName', cornerName)
          ..add('isRead', isRead)
          ..add('readAt', readAt)
          ..add('trackId', trackId)
          ..add('trackNo', trackNo))
        .toString();
  }
}

class BroadcastReceiptResponseBuilder
    implements
        Builder<BroadcastReceiptResponse, BroadcastReceiptResponseBuilder> {
  _$BroadcastReceiptResponse? _$v;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(int? trackNo) => _$this._trackNo = trackNo;

  BroadcastReceiptResponseBuilder() {
    BroadcastReceiptResponse._defaults(this);
  }

  BroadcastReceiptResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cornerName = $v.cornerName;
      _isRead = $v.isRead;
      _readAt = $v.readAt;
      _trackId = $v.trackId;
      _trackNo = $v.trackNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BroadcastReceiptResponse other) {
    _$v = other as _$BroadcastReceiptResponse;
  }

  @override
  void update(void Function(BroadcastReceiptResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BroadcastReceiptResponse build() => _build();

  _$BroadcastReceiptResponse _build() {
    final _$result = _$v ??
        _$BroadcastReceiptResponse._(
          cornerName: cornerName,
          isRead: isRead,
          readAt: readAt,
          trackId: trackId,
          trackNo: trackNo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
