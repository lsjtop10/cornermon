// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'group_stats_response.g.dart';

/// GroupStatsResponse
///
/// Properties:
/// * [completedCount] 
/// * [groupId] 
/// * [groupName] 
/// * [totalDurationSeconds] 
@BuiltValue()
abstract class GroupStatsResponse implements Built<GroupStatsResponse, GroupStatsResponseBuilder> {
  @BuiltValueField(wireName: r'completedCount')
  int? get completedCount;

  @BuiltValueField(wireName: r'groupId')
  String? get groupId;

  @BuiltValueField(wireName: r'groupName')
  String? get groupName;

  @BuiltValueField(wireName: r'totalDurationSeconds')
  int? get totalDurationSeconds;

  GroupStatsResponse._();

  factory GroupStatsResponse([void updates(GroupStatsResponseBuilder b)]) = _$GroupStatsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GroupStatsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GroupStatsResponse> get serializer => _$GroupStatsResponseSerializer();
}

class _$GroupStatsResponseSerializer implements PrimitiveSerializer<GroupStatsResponse> {
  @override
  final Iterable<Type> types = const [GroupStatsResponse, _$GroupStatsResponse];

  @override
  final String wireName = r'GroupStatsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GroupStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.completedCount != null) {
      yield r'completedCount';
      yield serializers.serialize(
        object.completedCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.groupId != null) {
      yield r'groupId';
      yield serializers.serialize(
        object.groupId,
        specifiedType: const FullType(String),
      );
    }
    if (object.groupName != null) {
      yield r'groupName';
      yield serializers.serialize(
        object.groupName,
        specifiedType: const FullType(String),
      );
    }
    if (object.totalDurationSeconds != null) {
      yield r'totalDurationSeconds';
      yield serializers.serialize(
        object.totalDurationSeconds,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GroupStatsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GroupStatsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'completedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedCount = valueDes;
          break;
        case r'groupId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        case r'groupName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupName = valueDes;
          break;
        case r'totalDurationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalDurationSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GroupStatsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GroupStatsResponseBuilder();
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
