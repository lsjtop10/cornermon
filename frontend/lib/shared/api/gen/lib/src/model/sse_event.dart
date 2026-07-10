//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sse_event.g.dart';

/// SSE 이벤트 형식. `event` 필드로 이벤트 타입을 구분하고, `data` 필드에 JSON 페이로드를 담는다. 모든 스냅샷 이벤트(`snapshot`)는 재연결 시에도 전체 현재 상태를 포함한다. 
///
/// Properties:
/// * [event] - 이벤트 타입
/// * [data] - 이벤트 타입별 JSON 페이로드
@BuiltValue()
abstract class SseEvent implements Built<SseEvent, SseEventBuilder> {
  /// 이벤트 타입
  @BuiltValueField(wireName: r'event')
  SseEventEventEnum? get event;
  // enum eventEnum {  snapshot,  visit.started,  visit.ended,  track.created,  track.deleted,  track.replaced,  corner.updated,  camp.started,  camp.ended,  message.broadcast,  message.direct,  session.force_logout,  device.approved,  lockout.alert,  };

  /// 이벤트 타입별 JSON 페이로드
  @BuiltValueField(wireName: r'data')
  JsonObject? get data;

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
        specifiedType: const FullType(JsonObject),
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
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.data = valueDes;
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

  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'snapshot')
  static const SseEventEventEnum snapshot = _$sseEventEventEnum_snapshot;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'visit.started')
  static const SseEventEventEnum visitPeriodStarted = _$sseEventEventEnum_visitPeriodStarted;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'visit.ended')
  static const SseEventEventEnum visitPeriodEnded = _$sseEventEventEnum_visitPeriodEnded;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'track.created')
  static const SseEventEventEnum trackPeriodCreated = _$sseEventEventEnum_trackPeriodCreated;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'track.deleted')
  static const SseEventEventEnum trackPeriodDeleted = _$sseEventEventEnum_trackPeriodDeleted;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'track.replaced')
  static const SseEventEventEnum trackPeriodReplaced = _$sseEventEventEnum_trackPeriodReplaced;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'corner.updated')
  static const SseEventEventEnum cornerPeriodUpdated = _$sseEventEventEnum_cornerPeriodUpdated;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'camp.started')
  static const SseEventEventEnum campPeriodStarted = _$sseEventEventEnum_campPeriodStarted;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'camp.ended')
  static const SseEventEventEnum campPeriodEnded = _$sseEventEventEnum_campPeriodEnded;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'message.broadcast')
  static const SseEventEventEnum messagePeriodBroadcast = _$sseEventEventEnum_messagePeriodBroadcast;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'message.direct')
  static const SseEventEventEnum messagePeriodDirect = _$sseEventEventEnum_messagePeriodDirect;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'session.force_logout')
  static const SseEventEventEnum sessionPeriodForceLogout = _$sseEventEventEnum_sessionPeriodForceLogout;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'device.approved')
  static const SseEventEventEnum devicePeriodApproved = _$sseEventEventEnum_devicePeriodApproved;
  /// 이벤트 타입
  @BuiltValueEnumConst(wireName: r'lockout.alert')
  static const SseEventEventEnum lockoutPeriodAlert = _$sseEventEventEnum_lockoutPeriodAlert;

  static Serializer<SseEventEventEnum> get serializer => _$sseEventEventEnumSerializer;

  const SseEventEventEnum._(String name): super(name);

  static BuiltSet<SseEventEventEnum> get values => _$sseEventEventEnumValues;
  static SseEventEventEnum valueOf(String name) => _$sseEventEventEnumValueOf(name);
}

