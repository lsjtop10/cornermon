// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_logs_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditLogsGet200Response extends AuditLogsGet200Response {
  @override
  final BuiltList<AuditLog>? logs;
  @override
  final bool? hasMore;

  factory _$AuditLogsGet200Response(
          [void Function(AuditLogsGet200ResponseBuilder)? updates]) =>
      (AuditLogsGet200ResponseBuilder()..update(updates))._build();

  _$AuditLogsGet200Response._({this.logs, this.hasMore}) : super._();
  @override
  AuditLogsGet200Response rebuild(
          void Function(AuditLogsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditLogsGet200ResponseBuilder toBuilder() =>
      AuditLogsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditLogsGet200Response &&
        logs == other.logs &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, logs.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditLogsGet200Response')
          ..add('logs', logs)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class AuditLogsGet200ResponseBuilder
    implements
        Builder<AuditLogsGet200Response, AuditLogsGet200ResponseBuilder> {
  _$AuditLogsGet200Response? _$v;

  ListBuilder<AuditLog>? _logs;
  ListBuilder<AuditLog> get logs => _$this._logs ??= ListBuilder<AuditLog>();
  set logs(ListBuilder<AuditLog>? logs) => _$this._logs = logs;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  AuditLogsGet200ResponseBuilder() {
    AuditLogsGet200Response._defaults(this);
  }

  AuditLogsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _logs = $v.logs?.toBuilder();
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditLogsGet200Response other) {
    _$v = other as _$AuditLogsGet200Response;
  }

  @override
  void update(void Function(AuditLogsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditLogsGet200Response build() => _build();

  _$AuditLogsGet200Response _build() {
    _$AuditLogsGet200Response _$result;
    try {
      _$result = _$v ??
          _$AuditLogsGet200Response._(
            logs: _logs?.build(),
            hasMore: hasMore,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'logs';
        _logs?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuditLogsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
