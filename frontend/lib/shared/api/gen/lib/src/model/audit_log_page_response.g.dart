// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.18

part of 'audit_log_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditLogPageResponse extends AuditLogPageResponse {
  @override
  final BuiltList<AuditLogResponse>? logs;
  @override
  final String? nextCursor;

  factory _$AuditLogPageResponse(
          [void Function(AuditLogPageResponseBuilder)? updates]) =>
      (AuditLogPageResponseBuilder()..update(updates))._build();

  _$AuditLogPageResponse._({this.logs, this.nextCursor}) : super._();
  @override
  AuditLogPageResponse rebuild(
          void Function(AuditLogPageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditLogPageResponseBuilder toBuilder() =>
      AuditLogPageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditLogPageResponse &&
        logs == other.logs &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, logs.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditLogPageResponse')
          ..add('logs', logs)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class AuditLogPageResponseBuilder
    implements Builder<AuditLogPageResponse, AuditLogPageResponseBuilder> {
  _$AuditLogPageResponse? _$v;

  ListBuilder<AuditLogResponse>? _logs;
  ListBuilder<AuditLogResponse> get logs =>
      _$this._logs ??= ListBuilder<AuditLogResponse>();
  set logs(ListBuilder<AuditLogResponse>? logs) => _$this._logs = logs;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  AuditLogPageResponseBuilder() {
    AuditLogPageResponse._defaults(this);
  }

  AuditLogPageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _logs = $v.logs?.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditLogPageResponse other) {
    _$v = other as _$AuditLogPageResponse;
  }

  @override
  void update(void Function(AuditLogPageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditLogPageResponse build() => _build();

  _$AuditLogPageResponse _build() {
    _$AuditLogPageResponse _$result;
    try {
      _$result = _$v ??
          _$AuditLogPageResponse._(
            logs: _logs?.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'logs';
        _logs?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuditLogPageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
