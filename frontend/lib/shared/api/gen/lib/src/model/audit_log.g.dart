// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditLog extends AuditLog {
  @override
  final String id;
  @override
  final String actor;
  @override
  final String action;
  @override
  final String target;
  @override
  final bool success;
  @override
  final DateTime occurredAt;
  @override
  final BuiltMap<String, JsonObject?>? metadata;

  factory _$AuditLog([void Function(AuditLogBuilder)? updates]) =>
      (AuditLogBuilder()..update(updates))._build();

  _$AuditLog._(
      {required this.id,
      required this.actor,
      required this.action,
      required this.target,
      required this.success,
      required this.occurredAt,
      this.metadata})
      : super._();
  @override
  AuditLog rebuild(void Function(AuditLogBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditLogBuilder toBuilder() => AuditLogBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditLog &&
        id == other.id &&
        actor == other.actor &&
        action == other.action &&
        target == other.target &&
        success == other.success &&
        occurredAt == other.occurredAt &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, actor.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditLog')
          ..add('id', id)
          ..add('actor', actor)
          ..add('action', action)
          ..add('target', target)
          ..add('success', success)
          ..add('occurredAt', occurredAt)
          ..add('metadata', metadata))
        .toString();
  }
}

class AuditLogBuilder implements Builder<AuditLog, AuditLogBuilder> {
  _$AuditLog? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _actor;
  String? get actor => _$this._actor;
  set actor(String? actor) => _$this._actor = actor;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _target;
  String? get target => _$this._target;
  set target(String? target) => _$this._target = target;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  MapBuilder<String, JsonObject?>? _metadata;
  MapBuilder<String, JsonObject?> get metadata =>
      _$this._metadata ??= MapBuilder<String, JsonObject?>();
  set metadata(MapBuilder<String, JsonObject?>? metadata) =>
      _$this._metadata = metadata;

  AuditLogBuilder() {
    AuditLog._defaults(this);
  }

  AuditLogBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _actor = $v.actor;
      _action = $v.action;
      _target = $v.target;
      _success = $v.success;
      _occurredAt = $v.occurredAt;
      _metadata = $v.metadata?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditLog other) {
    _$v = other as _$AuditLog;
  }

  @override
  void update(void Function(AuditLogBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditLog build() => _build();

  _$AuditLog _build() {
    _$AuditLog _$result;
    try {
      _$result = _$v ??
          _$AuditLog._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'AuditLog', 'id'),
            actor: BuiltValueNullFieldError.checkNotNull(
                actor, r'AuditLog', 'actor'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'AuditLog', 'action'),
            target: BuiltValueNullFieldError.checkNotNull(
                target, r'AuditLog', 'target'),
            success: BuiltValueNullFieldError.checkNotNull(
                success, r'AuditLog', 'success'),
            occurredAt: BuiltValueNullFieldError.checkNotNull(
                occurredAt, r'AuditLog', 'occurredAt'),
            metadata: _metadata?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metadata';
        _metadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuditLog', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
