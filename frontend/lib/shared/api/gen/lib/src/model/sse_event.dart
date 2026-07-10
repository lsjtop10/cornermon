//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/sse_notification_data.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sse_event.g.dart';

/// SSE 알림 형식 (§technical-design.md 2.3, 하이브리드 알림+풀 모델). **SSE는 데이터를 나르지 않는다** — `event` 필드로 알림 타입, `data.scope` 필드로 어떤 리소스가 변경됐는지만 알린다. 실제 값은 항상 REST가 유일한 출처이며, 클라이언트는 알림을 받으면 `scope`에 대응하는 REST 엔드포인트를 재조회해야 한다 (아래 매핑 참고, §/events/admin, §/events/track/{trackId}). 연결/재연결 시 서버가 별도의 초기 스냅샷을 push하지 않는다 — 화면 진입 시 클라이언트가 REST로 최초 조회를 직접 수행한다. 
///
/// Properties:
/// * [event] - 알림 타입
/// * [data] 
@BuiltValue()
abstract class SseEvent implements Built<SseEvent, SseEventBuilder> {
  /// 알림 타입
  @BuiltValueField(wireName: r'event')
  SseEventEventEnum? get event;
  // enum eventEnum {  tracks_updated,  track_updated,  corners_updated,  groups_updated,  camp_updated,  messages_changed,  track_deleted,  session_revoked,  camp_ended,  device_registration_updated,  lockout_alert,  };

  @BuiltValueField(wireName: r'data')
  SseNotificationData? get data;

  SseEvent._();

  factory SseEvent([void updates(SseEventBuilder b)]) = _$SseEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SseEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SseEvent> get serializer => _$SseEventSerializer();
}

class _$SseEventSerializer implements PrimitiveSerializer<SseEvent> {
  @override
  final Iterable<Type> types = const [SseEvent, _$SseEvent];

  @override
  final String wireName = r'SseEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SseEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.event != null) {
      yield r'event';
      yield serializers.serialize(
        object.event,
        specifiedType: const FullType(SseEventEventEnum),
      );
    }
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(SseNotificationData),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SseEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SseEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'event':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SseEventEventEnum),
          ) as SseEventEventEnum;
          result.event = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SseNotificationData),
          ) as SseNotificationData;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SseEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SseEventBuilder();
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

class SseEventEventEnum extends EnumClass {

  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'tracks_updated')
  static const SseEventEventEnum tracksUpdated = _$sseEventEventEnum_tracksUpdated;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'track_updated')
  static const SseEventEventEnum trackUpdated = _$sseEventEventEnum_trackUpdated;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'corners_updated')
  static const SseEventEventEnum cornersUpdated = _$sseEventEventEnum_cornersUpdated;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'groups_updated')
  static const SseEventEventEnum groupsUpdated = _$sseEventEventEnum_groupsUpdated;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'camp_updated')
  static const SseEventEventEnum campUpdated = _$sseEventEventEnum_campUpdated;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'messages_changed')
  static const SseEventEventEnum messagesChanged = _$sseEventEventEnum_messagesChanged;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'track_deleted')
  static const SseEventEventEnum trackDeleted = _$sseEventEventEnum_trackDeleted;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'session_revoked')
  static const SseEventEventEnum sessionRevoked = _$sseEventEventEnum_sessionRevoked;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'camp_ended')
  static const SseEventEventEnum campEnded = _$sseEventEventEnum_campEnded;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'device_registration_updated')
  static const SseEventEventEnum deviceRegistrationUpdated = _$sseEventEventEnum_deviceRegistrationUpdated;
  /// 알림 타입
  @BuiltValueEnumConst(wireName: r'lockout_alert')
  static const SseEventEventEnum lockoutAlert = _$sseEventEventEnum_lockoutAlert;

  static Serializer<SseEventEventEnum> get serializer => _$sseEventEventEnumSerializer;

  const SseEventEventEnum._(String name): super(name);

  static BuiltSet<SseEventEventEnum> get values => _$sseEventEventEnumValues;
  static SseEventEventEnum valueOf(String name) => _$sseEventEventEnumValueOf(name);
}

