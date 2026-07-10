//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sse_notification_data.g.dart';

/// 알림 페이로드. `scope` 외 다른 데이터를 담지 않는다.
///
/// Properties:
/// * [scope] - 변경된 리소스의 범위. 클라이언트는 이 값만 보고 재조회할 REST 엔드포인트를 결정한다. - `camp` → 캠프 전역 리소스(코너/조/트랙 목록/캠프 상태/기기 등록 목록) - `track:{trackId}` → 특정 트랙의 상태 또는 메시지 스레드 - `broadcast` → 공지 채널 - `device:{deviceId}` → 특정 기기 등록 건 
@BuiltValue()
abstract class SseNotificationData implements Built<SseNotificationData, SseNotificationDataBuilder> {
  /// 변경된 리소스의 범위. 클라이언트는 이 값만 보고 재조회할 REST 엔드포인트를 결정한다. - `camp` → 캠프 전역 리소스(코너/조/트랙 목록/캠프 상태/기기 등록 목록) - `track:{trackId}` → 특정 트랙의 상태 또는 메시지 스레드 - `broadcast` → 공지 채널 - `device:{deviceId}` → 특정 기기 등록 건 
  @BuiltValueField(wireName: r'scope')
  String get scope;

  SseNotificationData._();

  factory SseNotificationData([void updates(SseNotificationDataBuilder b)]) = _$SseNotificationData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SseNotificationDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SseNotificationData> get serializer => _$SseNotificationDataSerializer();
}

class _$SseNotificationDataSerializer implements PrimitiveSerializer<SseNotificationData> {
  @override
  final Iterable<Type> types = const [SseNotificationData, _$SseNotificationData];

  @override
  final String wireName = r'SseNotificationData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SseNotificationData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SseNotificationData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SseNotificationDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scope = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SseNotificationData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SseNotificationDataBuilder();
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

