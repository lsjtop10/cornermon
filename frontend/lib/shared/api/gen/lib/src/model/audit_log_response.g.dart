// @dart=2.18
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditLogResponse extends AuditLogResponse {
  @override
  final String? action;
  @override
  final String? actor;
  @override
  final String? id;
  @override
  final BuiltMap<String, JsonObject?>? metadata;
  @override
  final DateTime? occurredAt;
  @override
  final bool? success;
  @override
  final String? target;

  factory _$AuditLogResponse(
          [void Function(AuditLogResponseBuilder)? updates]) =>
      (AuditLogResponseBuilder()..update(updates))._build();

  _$AuditLogResponse._(
      {this.action,
      this.actor,
      this.id,
      this.metadata,
      this.occurredAt,
      this.success,
      this.target})
      : super._();
  @override
  AuditLogResponse rebuild(void Function(AuditLogResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditLogResponseBuilder toBuilder() =>
      AuditLogResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditLogResponse &&
        action == other.action &&
        actor == other.actor &&
        id == other.id &&
        metadata == other.metadata &&
        occurredAt == other.occurredAt &&
        success == other.success &&
        target == other.target;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, actor.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditLogResponse')
          ..add('action', action)
          ..add('actor', actor)
          ..add('id', id)
          ..add('metadata', metadata)
          ..add('occurredAt', occurredAt)
          ..add('success', success)
          ..add('target', target))
        .toString();
  }
}

class AuditLogResponseBuilder
    implements Builder<AuditLogResponse, AuditLogResponseBuilder> {
  _$AuditLogResponse? _$v;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _actor;
  String? get actor => _$this._actor;
  set actor(String? actor) => _$this._actor = actor;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _target;
  String? get target => _$this._target;
  set target(String? target) => _$this._target = target;

  AuditLogResponseBuilder() {
    AuditLogResponse._defaults(this);
  }

  AuditLogResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _actor = $v.actor;
      _id = $v.id;
      _metadata = $v.metadata?.toBuilder();
      _occurredAt = $v.occurredAt;
      _success = $v.success;
      _target = $v.target;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditLogResponse other) {
    _$v = other as _$AuditLogResponse;
  }

  @override
  void update(void Function(AuditLogResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditLogResponse build() => _build();

  _$AuditLogResponse _build() {
    _$AuditLogResponse _$result;
    try {
      _$result = _$v ??
          _$AuditLogResponse._(
            action: action,
            actor: actor,
            id: id,
            metadata: _metadata?.build(),
            occurredAt: occurredAt,
            success: success,
            target: target,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuditLogResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
