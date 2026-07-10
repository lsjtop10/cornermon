//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'group_stats_unvisited_corners_inner.g.dart';

/// GroupStatsUnvisitedCornersInner
///
/// Properties:
/// * [cornerId] 
/// * [cornerName] 
@BuiltValue()
abstract class GroupStatsUnvisitedCornersInner implements Built<GroupStatsUnvisitedCornersInner, GroupStatsUnvisitedCornersInnerBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  GroupStatsUnvisitedCornersInner._();

  factory GroupStatsUnvisitedCornersInner([void updates(GroupStatsUnvisitedCornersInnerBuilder b)]) = _$GroupStatsUnvisitedCornersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GroupStatsUnvisitedCornersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GroupStatsUnvisitedCornersInner> get serializer => _$GroupStatsUnvisitedCornersInnerSerializer();
}

class _$GroupStatsUnvisitedCornersInnerSerializer implements PrimitiveSerializer<GroupStatsUnvisitedCornersInner> {
  @override
  final Iterable<Type> types = const [GroupStatsUnvisitedCornersInner, _$GroupStatsUnvisitedCornersInner];

  @override
  final String wireName = r'GroupStatsUnvisitedCornersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GroupStatsUnvisitedCornersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cornerId != null) {
      yield r'cornerId';
      yield serializers.serialize(
        object.cornerId,
        specifiedType: const FullType(String),
      );
    }
    if (object.cornerName != null) {
      yield r'cornerName';
      yield serializers.serialize(
        object.cornerName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GroupStatsUnvisitedCornersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GroupStatsUnvisitedCornersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        case r'cornerName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GroupStatsUnvisitedCornersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GroupStatsUnvisitedCornersInnerBuilder();
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

