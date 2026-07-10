// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_receipt.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BroadcastReceipt extends BroadcastReceipt {
  @override
  final String trackId;
  @override
  final int? trackNo;
  @override
  final String? cornerName;
  @override
  final bool isRead;
  @override
  final DateTime? readAt;

  factory _$BroadcastReceipt([
    void Function(BroadcastReceiptBuilder)? updates,
  ]) => (BroadcastReceiptBuilder()..update(updates))._build();

  _$BroadcastReceipt._({
    required this.trackId,
    this.trackNo,
    this.cornerName,
    required this.isRead,
    this.readAt,
  }) : super._();
  @override
  BroadcastReceipt rebuild(void Function(BroadcastReceiptBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BroadcastReceiptBuilder toBuilder() =>
      BroadcastReceiptBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BroadcastReceipt &&
        trackId == other.trackId &&
        trackNo == other.trackNo &&
        cornerName == other.cornerName &&
        isRead == other.isRead &&
        readAt == other.readAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trackId.hashCode);
    _$hash = $jc(_$hash, trackNo.hashCode);
    _$hash = $jc(_$hash, cornerName.hashCode);
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BroadcastReceipt')
          ..add('trackId', trackId)
          ..add('trackNo', trackNo)
          ..add('cornerName', cornerName)
          ..add('isRead', isRead)
          ..add('readAt', readAt))
        .toString();
  }
}

class BroadcastReceiptBuilder
    implements Builder<BroadcastReceipt, BroadcastReceiptBuilder> {
  _$BroadcastReceipt? _$v;

  String? _trackId;
  String? get trackId => _$this._trackId;
  set trackId(String? trackId) => _$this._trackId = trackId;

  int? _trackNo;
  int? get trackNo => _$this._trackNo;
  set trackNo(int? trackNo) => _$this._trackNo = trackNo;

  String? _cornerName;
  String? get cornerName => _$this._cornerName;
  set cornerName(String? cornerName) => _$this._cornerName = cornerName;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  BroadcastReceiptBuilder() {
    BroadcastReceipt._defaults(this);
  }

  BroadcastReceiptBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trackId = $v.trackId;
      _trackNo = $v.trackNo;
      _cornerName = $v.cornerName;
      _isRead = $v.isRead;
      _readAt = $v.readAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BroadcastReceipt other) {
    _$v = other as _$BroadcastReceipt;
  }

  @override
  void update(void Function(BroadcastReceiptBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BroadcastReceipt build() => _build();

  _$BroadcastReceipt _build() {
    final _$result =
        _$v ??
        _$BroadcastReceipt._(
          trackId: BuiltValueNullFieldError.checkNotNull(
            trackId,
            r'BroadcastReceipt',
            'trackId',
          ),
          trackNo: trackNo,
          cornerName: cornerName,
          isRead: BuiltValueNullFieldError.checkNotNull(
            isRead,
            r'BroadcastReceipt',
            'isRead',
          ),
          readAt: readAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
