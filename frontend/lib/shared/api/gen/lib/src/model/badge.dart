//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/badge_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'badge.g.dart';

/// Badge
///
/// Properties:
/// * [id] 
/// * [shortId] - 사람이 읽을 수 있는 짧은 ID (인쇄용)
/// * [qrPayload] - QR 코드에 인코딩된 페이로드 (관리자만 조회 가능)
/// * [status] 
/// * [assignedGroupId] 
@BuiltValue()
abstract class Badge implements Built<Badge, BadgeBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 사람이 읽을 수 있는 짧은 ID (인쇄용)
  @BuiltValueField(wireName: r'shortId')
  String get shortId;

  /// QR 코드에 인코딩된 페이로드 (관리자만 조회 가능)
  @BuiltValueField(wireName: r'qrPayload')
  String? get qrPayload;

  @BuiltValueField(wireName: r'status')
  BadgeStatus get status;
  // enum statusEnum {  UNASSIGNED,  ASSIGNED,  };

  @BuiltValueField(wireName: r'assignedGroupId')
  String? get assignedGroupId;

  Badge._();

  factory Badge([void updates(BadgeBuilder b)]) = _$Badge;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadgeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Badge> get serializer => _$BadgeSerializer();
}

class _$BadgeSerializer implements PrimitiveSerializer<Badge> {
  @override
  final Iterable<Type> types = const [Badge, _$Badge];

  @override
  final String wireName = r'Badge';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Badge object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'shortId';
    yield serializers.serialize(
      object.shortId,
      specifiedType: const FullType(String),
    );
    if (object.qrPayload != null) {
      yield r'qrPayload';
      yield serializers.serialize(
        object.qrPayload,
        specifiedType: const FullType(String),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(BadgeStatus),
    );
    if (object.assignedGroupId != null) {
      yield r'assignedGroupId';
      yield serializers.serialize(
        object.assignedGroupId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Badge object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadgeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'shortId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shortId = valueDes;
          break;
        case r'qrPayload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrPayload = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BadgeStatus),
          ) as BadgeStatus;
          result.status = valueDes;
          break;
        case r'assignedGroupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedGroupId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Badge deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadgeBuilder();
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

