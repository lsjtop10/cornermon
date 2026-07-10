//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_stats_unvisited_groups_inner.g.dart';

/// CornerStatsUnvisitedGroupsInner
///
/// Properties:
/// * [groupId] 
/// * [groupName] 
@BuiltValue()
abstract class CornerStatsUnvisitedGroupsInner implements Built<CornerStatsUnvisitedGroupsInner, CornerStatsUnvisitedGroupsInnerBuilder> {
  @BuiltValueField(wireName: r'groupId')
  String? get groupId;

  @BuiltValueField(wireName: r'groupName')
  String? get groupName;

  CornerStatsUnvisitedGroupsInner._();

  factory CornerStatsUnvisitedGroupsInner([void updates(CornerStatsUnvisitedGroupsInnerBuilder b)]) = _$CornerStatsUnvisitedGroupsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerStatsUnvisitedGroupsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerStatsUnvisitedGroupsInner> get serializer => _$CornerStatsUnvisitedGroupsInnerSerializer();
}

class _$CornerStatsUnvisitedGroupsInnerSerializer implements PrimitiveSerializer<CornerStatsUnvisitedGroupsInner> {
  @override
  final Iterable<Type> types = const [CornerStatsUnvisitedGroupsInner, _$CornerStatsUnvisitedGroupsInner];

  @override
  final String wireName = r'CornerStatsUnvisitedGroupsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerStatsUnvisitedGroupsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerStatsUnvisitedGroupsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerStatsUnvisitedGroupsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerStatsUnvisitedGroupsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerStatsUnvisitedGroupsInnerBuilder();
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

