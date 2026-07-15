// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/sse_scope.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sse_notification.g.dart';

/// SSENotification
///
/// Properties:
/// * [event] 
/// * [scope] 
@BuiltValue()
abstract class SSENotification implements Built<SSENotification, SSENotificationBuilder> {
  @BuiltValueField(wireName: r'event')
  SSENotificationEventEnum? get event;
  // enum eventEnum {  tracks_updated,  track_updated,  corners_updated,  groups_updated,  camp_updated,  messages_changed,  track_deleted,  track_replaced,  session_revoked,  camp_ended,  device_registration_updated,  lockout_alert,  };

  @BuiltValueField(wireName: r'scope')
  SSEScope? get scope;

  SSENotification._();

  factory SSENotification([void updates(SSENotificationBuilder b)]) = _$SSENotification;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SSENotificationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SSENotification> get serializer => _$SSENotificationSerializer();
}

class _$SSENotificationSerializer implements PrimitiveSerializer<SSENotification> {
  @override
  final Iterable<Type> types = const [SSENotification, _$SSENotification];

  @override
  final String wireName = r'SSENotification';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SSENotification object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.event != null) {
      yield r'event';
      yield serializers.serialize(
        object.event,
        specifiedType: const FullType(SSENotificationEventEnum),
      );
    }
    if (object.scope != null) {
      yield r'scope';
      yield serializers.serialize(
        object.scope,
        specifiedType: const FullType(SSEScope),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SSENotification object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SSENotificationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'event':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SSENotificationEventEnum),
          ) as SSENotificationEventEnum;
          result.event = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SSEScope),
          ) as SSEScope;
          result.scope.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SSENotification deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SSENotificationBuilder();
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

class SSENotificationEventEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'tracks_updated')
  static const SSENotificationEventEnum tracksUpdated = _$sSENotificationEventEnum_tracksUpdated;
  @BuiltValueEnumConst(wireName: r'track_updated')
  static const SSENotificationEventEnum trackUpdated = _$sSENotificationEventEnum_trackUpdated;
  @BuiltValueEnumConst(wireName: r'corners_updated')
  static const SSENotificationEventEnum cornersUpdated = _$sSENotificationEventEnum_cornersUpdated;
  @BuiltValueEnumConst(wireName: r'groups_updated')
  static const SSENotificationEventEnum groupsUpdated = _$sSENotificationEventEnum_groupsUpdated;
  @BuiltValueEnumConst(wireName: r'camp_updated')
  static const SSENotificationEventEnum campUpdated = _$sSENotificationEventEnum_campUpdated;
  @BuiltValueEnumConst(wireName: r'messages_changed')
  static const SSENotificationEventEnum messagesChanged = _$sSENotificationEventEnum_messagesChanged;
  @BuiltValueEnumConst(wireName: r'track_deleted')
  static const SSENotificationEventEnum trackDeleted = _$sSENotificationEventEnum_trackDeleted;
  @BuiltValueEnumConst(wireName: r'track_replaced')
  static const SSENotificationEventEnum trackReplaced = _$sSENotificationEventEnum_trackReplaced;
  @BuiltValueEnumConst(wireName: r'session_revoked')
  static const SSENotificationEventEnum sessionRevoked = _$sSENotificationEventEnum_sessionRevoked;
  @BuiltValueEnumConst(wireName: r'camp_ended')
  static const SSENotificationEventEnum campEnded = _$sSENotificationEventEnum_campEnded;
  @BuiltValueEnumConst(wireName: r'device_registration_updated')
  static const SSENotificationEventEnum deviceRegistrationUpdated = _$sSENotificationEventEnum_deviceRegistrationUpdated;
  @BuiltValueEnumConst(wireName: r'lockout_alert')
  static const SSENotificationEventEnum lockoutAlert = _$sSENotificationEventEnum_lockoutAlert;

  static Serializer<SSENotificationEventEnum> get serializer => _$sSENotificationEventEnumSerializer;

  const SSENotificationEventEnum._(String name): super(name);

  static BuiltSet<SSENotificationEventEnum> get values => _$sSENotificationEventEnumValues;
  static SSENotificationEventEnum valueOf(String name) => _$sSENotificationEventEnumValueOf(name);
}
