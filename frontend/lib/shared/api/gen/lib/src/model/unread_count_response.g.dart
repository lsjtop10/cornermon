// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'unread_count_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UnreadCountResponse extends UnreadCountResponse {
  @override
  final int? unreadCount;

  factory _$UnreadCountResponse(
          [void Function(UnreadCountResponseBuilder)? updates]) =>
      (UnreadCountResponseBuilder()..update(updates))._build();

  _$UnreadCountResponse._({this.unreadCount}) : super._();
  @override
  UnreadCountResponse rebuild(
          void Function(UnreadCountResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UnreadCountResponseBuilder toBuilder() =>
      UnreadCountResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnreadCountResponse && unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UnreadCountResponse')
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class UnreadCountResponseBuilder
    implements Builder<UnreadCountResponse, UnreadCountResponseBuilder> {
  _$UnreadCountResponse? _$v;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  UnreadCountResponseBuilder() {
    UnreadCountResponse._defaults(this);
  }

  UnreadCountResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnreadCountResponse other) {
    _$v = other as _$UnreadCountResponse;
  }

  @override
  void update(void Function(UnreadCountResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnreadCountResponse build() => _build();

  _$UnreadCountResponse _build() {
    final _$result = _$v ??
        _$UnreadCountResponse._(
          unreadCount: unreadCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
