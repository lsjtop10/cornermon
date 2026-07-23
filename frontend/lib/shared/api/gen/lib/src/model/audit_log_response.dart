// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'audit_log_response.g.dart';

/// AuditLogResponse
///
/// Properties:
/// * [action] 
/// * [actor] 
/// * [actorName] 
/// * [campId] 
/// * [id] 
/// * [metadata] 
/// * [occurredAt] 
/// * [success] 
/// * [target] 
/// * [targetName] 
@BuiltValue()
abstract class AuditLogResponse implements Built<AuditLogResponse, AuditLogResponseBuilder> {
  @BuiltValueField(wireName: r'action')
  AuditLogResponseActionEnum? get action;
  // enum actionEnum {  ADMIN_LOGIN,  ADMIN_CREATE,  ADMIN_PASSWORD_CHANGE,  ADMIN_DELETE,  ADMIN_SESSION_REVOKE,  TRACK_FORCE_LOGOUT,  FACILITATOR_LOGIN,  SESSION_MIGRATE,  FACILITATOR_LOGOUT,  BADGE_ASSIGN,  BADGE_BULK_GENERATE,  BADGE_EXPORT,  CAMP_ACTIVATE,  CAMP_END,  CAMP_CREATE,  CAMP_SETTINGS_UPDATE,  CORNER_UPDATE,  CORNER_DELETE,  CORNER_CREATE,  DEVICE_APPROVED,  DEVICE_REJECTED,  DEVICE_REVOKED,  PIN_LOCK_RESET,  DEVICE_REQUEST,  GROUP_CREATE,  MESSAGE_DIRECT,  MESSAGE_BROADCAST,  TRACK_CREATE,  TRACK_DELETE,  TRACK_REPLACE,  PIN_REGENERATE,  TRACK_PIN_EXPORT,  VISIT_START,  VISIT_COMPLETE,  };

  @BuiltValueField(wireName: r'actor')
  String? get actor;

  @BuiltValueField(wireName: r'actorName')
  String? get actorName;

  @BuiltValueField(wireName: r'campId')
  String? get campId;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'metadata')
  BuiltMap<String, JsonObject?>? get metadata;

  @BuiltValueField(wireName: r'occurredAt')
  DateTime? get occurredAt;

  @BuiltValueField(wireName: r'success')
  bool? get success;

  @BuiltValueField(wireName: r'target')
  String? get target;

  @BuiltValueField(wireName: r'targetName')
  String? get targetName;

  AuditLogResponse._();

  factory AuditLogResponse([void updates(AuditLogResponseBuilder b)]) = _$AuditLogResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuditLogResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuditLogResponse> get serializer => _$AuditLogResponseSerializer();
}

class _$AuditLogResponseSerializer implements PrimitiveSerializer<AuditLogResponse> {
  @override
  final Iterable<Type> types = const [AuditLogResponse, _$AuditLogResponse];

  @override
  final String wireName = r'AuditLogResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuditLogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(AuditLogResponseActionEnum),
      );
    }
    if (object.actor != null) {
      yield r'actor';
      yield serializers.serialize(
        object.actor,
        specifiedType: const FullType(String),
      );
    }
    if (object.actorName != null) {
      yield r'actorName';
      yield serializers.serialize(
        object.actorName,
        specifiedType: const FullType(String),
      );
    }
    if (object.campId != null) {
      yield r'campId';
      yield serializers.serialize(
        object.campId,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.occurredAt != null) {
      yield r'occurredAt';
      yield serializers.serialize(
        object.occurredAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.success != null) {
      yield r'success';
      yield serializers.serialize(
        object.success,
        specifiedType: const FullType(bool),
      );
    }
    if (object.target != null) {
      yield r'target';
      yield serializers.serialize(
        object.target,
        specifiedType: const FullType(String),
      );
    }
    if (object.targetName != null) {
      yield r'targetName';
      yield serializers.serialize(
        object.targetName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuditLogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuditLogResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuditLogResponseActionEnum),
          ) as AuditLogResponseActionEnum;
          result.action = valueDes;
          break;
        case r'actor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actor = valueDes;
          break;
        case r'actorName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actorName = valueDes;
          break;
        case r'campId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.campId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.metadata.replace(valueDes);
          break;
        case r'occurredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
          break;
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.success = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.target = valueDes;
          break;
        case r'targetName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuditLogResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuditLogResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class AuditLogResponseActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ADMIN_LOGIN')
  static const AuditLogResponseActionEnum ADMIN_LOGIN = _$auditLogResponseActionEnum_ADMIN_LOGIN;
  @BuiltValueEnumConst(wireName: r'ADMIN_CREATE')
  static const AuditLogResponseActionEnum ADMIN_CREATE = _$auditLogResponseActionEnum_ADMIN_CREATE;
  @BuiltValueEnumConst(wireName: r'ADMIN_PASSWORD_CHANGE')
  static const AuditLogResponseActionEnum ADMIN_PASSWORD_CHANGE = _$auditLogResponseActionEnum_ADMIN_PASSWORD_CHANGE;
  @BuiltValueEnumConst(wireName: r'ADMIN_DELETE')
  static const AuditLogResponseActionEnum ADMIN_DELETE = _$auditLogResponseActionEnum_ADMIN_DELETE;
  @BuiltValueEnumConst(wireName: r'ADMIN_SESSION_REVOKE')
  static const AuditLogResponseActionEnum ADMIN_SESSION_REVOKE = _$auditLogResponseActionEnum_ADMIN_SESSION_REVOKE;
  @BuiltValueEnumConst(wireName: r'TRACK_FORCE_LOGOUT')
  static const AuditLogResponseActionEnum TRACK_FORCE_LOGOUT = _$auditLogResponseActionEnum_TRACK_FORCE_LOGOUT;
  @BuiltValueEnumConst(wireName: r'FACILITATOR_LOGIN')
  static const AuditLogResponseActionEnum FACILITATOR_LOGIN = _$auditLogResponseActionEnum_FACILITATOR_LOGIN;
  @BuiltValueEnumConst(wireName: r'SESSION_MIGRATE')
  static const AuditLogResponseActionEnum SESSION_MIGRATE = _$auditLogResponseActionEnum_SESSION_MIGRATE;
  @BuiltValueEnumConst(wireName: r'FACILITATOR_LOGOUT')
  static const AuditLogResponseActionEnum FACILITATOR_LOGOUT = _$auditLogResponseActionEnum_FACILITATOR_LOGOUT;
  @BuiltValueEnumConst(wireName: r'BADGE_ASSIGN')
  static const AuditLogResponseActionEnum BADGE_ASSIGN = _$auditLogResponseActionEnum_BADGE_ASSIGN;
  @BuiltValueEnumConst(wireName: r'BADGE_BULK_GENERATE')
  static const AuditLogResponseActionEnum BADGE_BULK_GENERATE = _$auditLogResponseActionEnum_BADGE_BULK_GENERATE;
  @BuiltValueEnumConst(wireName: r'BADGE_EXPORT')
  static const AuditLogResponseActionEnum BADGE_EXPORT = _$auditLogResponseActionEnum_BADGE_EXPORT;
  @BuiltValueEnumConst(wireName: r'CAMP_ACTIVATE')
  static const AuditLogResponseActionEnum CAMP_ACTIVATE = _$auditLogResponseActionEnum_CAMP_ACTIVATE;
  @BuiltValueEnumConst(wireName: r'CAMP_END')
  static const AuditLogResponseActionEnum CAMP_END = _$auditLogResponseActionEnum_CAMP_END;
  @BuiltValueEnumConst(wireName: r'CAMP_CREATE')
  static const AuditLogResponseActionEnum CAMP_CREATE = _$auditLogResponseActionEnum_CAMP_CREATE;
  @BuiltValueEnumConst(wireName: r'CAMP_SETTINGS_UPDATE')
  static const AuditLogResponseActionEnum CAMP_SETTINGS_UPDATE = _$auditLogResponseActionEnum_CAMP_SETTINGS_UPDATE;
  @BuiltValueEnumConst(wireName: r'CORNER_UPDATE')
  static const AuditLogResponseActionEnum CORNER_UPDATE = _$auditLogResponseActionEnum_CORNER_UPDATE;
  @BuiltValueEnumConst(wireName: r'CORNER_DELETE')
  static const AuditLogResponseActionEnum CORNER_DELETE = _$auditLogResponseActionEnum_CORNER_DELETE;
  @BuiltValueEnumConst(wireName: r'CORNER_CREATE')
  static const AuditLogResponseActionEnum CORNER_CREATE = _$auditLogResponseActionEnum_CORNER_CREATE;
  @BuiltValueEnumConst(wireName: r'DEVICE_APPROVED')
  static const AuditLogResponseActionEnum DEVICE_APPROVED = _$auditLogResponseActionEnum_DEVICE_APPROVED;
  @BuiltValueEnumConst(wireName: r'DEVICE_REJECTED')
  static const AuditLogResponseActionEnum DEVICE_REJECTED = _$auditLogResponseActionEnum_DEVICE_REJECTED;
  @BuiltValueEnumConst(wireName: r'DEVICE_REVOKED')
  static const AuditLogResponseActionEnum DEVICE_REVOKED = _$auditLogResponseActionEnum_DEVICE_REVOKED;
  @BuiltValueEnumConst(wireName: r'PIN_LOCK_RESET')
  static const AuditLogResponseActionEnum PIN_LOCK_RESET = _$auditLogResponseActionEnum_PIN_LOCK_RESET;
  @BuiltValueEnumConst(wireName: r'DEVICE_REQUEST')
  static const AuditLogResponseActionEnum DEVICE_REQUEST = _$auditLogResponseActionEnum_DEVICE_REQUEST;
  @BuiltValueEnumConst(wireName: r'GROUP_CREATE')
  static const AuditLogResponseActionEnum GROUP_CREATE = _$auditLogResponseActionEnum_GROUP_CREATE;
  @BuiltValueEnumConst(wireName: r'MESSAGE_DIRECT')
  static const AuditLogResponseActionEnum MESSAGE_DIRECT = _$auditLogResponseActionEnum_MESSAGE_DIRECT;
  @BuiltValueEnumConst(wireName: r'MESSAGE_BROADCAST')
  static const AuditLogResponseActionEnum MESSAGE_BROADCAST = _$auditLogResponseActionEnum_MESSAGE_BROADCAST;
  @BuiltValueEnumConst(wireName: r'TRACK_CREATE')
  static const AuditLogResponseActionEnum TRACK_CREATE = _$auditLogResponseActionEnum_TRACK_CREATE;
  @BuiltValueEnumConst(wireName: r'TRACK_DELETE')
  static const AuditLogResponseActionEnum TRACK_DELETE = _$auditLogResponseActionEnum_TRACK_DELETE;
  @BuiltValueEnumConst(wireName: r'TRACK_REPLACE')
  static const AuditLogResponseActionEnum TRACK_REPLACE = _$auditLogResponseActionEnum_TRACK_REPLACE;
  @BuiltValueEnumConst(wireName: r'PIN_REGENERATE')
  static const AuditLogResponseActionEnum PIN_REGENERATE = _$auditLogResponseActionEnum_PIN_REGENERATE;
  @BuiltValueEnumConst(wireName: r'TRACK_PIN_EXPORT')
  static const AuditLogResponseActionEnum TRACK_PIN_EXPORT = _$auditLogResponseActionEnum_TRACK_PIN_EXPORT;
  @BuiltValueEnumConst(wireName: r'VISIT_START')
  static const AuditLogResponseActionEnum VISIT_START = _$auditLogResponseActionEnum_VISIT_START;
  @BuiltValueEnumConst(wireName: r'VISIT_COMPLETE')
  static const AuditLogResponseActionEnum VISIT_COMPLETE = _$auditLogResponseActionEnum_VISIT_COMPLETE;

  static Serializer<AuditLogResponseActionEnum> get serializer => _$auditLogResponseActionEnumSerializer;

  const AuditLogResponseActionEnum._(String name): super(name);

  static BuiltSet<AuditLogResponseActionEnum> get values => _$auditLogResponseActionEnumValues;
  static AuditLogResponseActionEnum valueOf(String name) => _$auditLogResponseActionEnumValueOf(name);
}
