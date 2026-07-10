// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_notification_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SseNotificationData extends SseNotificationData {
  @override
  final String scope;

  factory _$SseNotificationData([
    void Function(SseNotificationDataBuilder)? updates,
  ]) => (SseNotificationDataBuilder()..update(updates))._build();

  _$SseNotificationData._({required this.scope}) : super._();
  @override
  SseNotificationData rebuild(
    void Function(SseNotificationDataBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SseNotificationDataBuilder toBuilder() =>
      SseNotificationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SseNotificationData && scope == other.scope;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SseNotificationData',
    )..add('scope', scope)).toString();
  }
}

class SseNotificationDataBuilder
    implements Builder<SseNotificationData, SseNotificationDataBuilder> {
  _$SseNotificationData? _$v;

  String? _scope;
  String? get scope => _$this._scope;
  set scope(String? scope) => _$this._scope = scope;

  SseNotificationDataBuilder() {
    SseNotificationData._defaults(this);
  }

  SseNotificationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _scope = $v.scope;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SseNotificationData other) {
    _$v = other as _$SseNotificationData;
  }

  @override
  void update(void Function(SseNotificationDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SseNotificationData build() => _build();

  _$SseNotificationData _build() {
    final _$result =
        _$v ??
        _$SseNotificationData._(
          scope: BuiltValueNullFieldError.checkNotNull(
            scope,
            r'SseNotificationData',
            'scope',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
