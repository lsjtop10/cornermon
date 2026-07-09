//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'group_stats_corner_durations_inner.g.dart';

/// GroupStatsCornerDurationsInner
///
/// Properties:
/// * [cornerId] 
/// * [cornerName] 
/// * [durationSeconds] 
@BuiltValue()
abstract class GroupStatsCornerDurationsInner implements Built<GroupStatsCornerDurationsInner, GroupStatsCornerDurationsInnerBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String? get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'durationSeconds')
  int? get durationSeconds;

  GroupStatsCornerDurationsInner._();

  factory GroupStatsCornerDurationsInner([void updates(GroupStatsCornerDurationsInnerBuilder b)]) = _$GroupStatsCornerDurationsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GroupStatsCornerDurationsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GroupStatsCornerDurationsInner> get serializer => _$GroupStatsCornerDurationsInnerSerializer();
}

class _$GroupStatsCornerDurationsInnerSerializer implements PrimitiveSerializer<GroupStatsCornerDurationsInner> {
  @override
  final Iterable<Type> types = const [GroupStatsCornerDurationsInner, _$GroupStatsCornerDurationsInner];

  @override
  final String wireName = r'GroupStatsCornerDurationsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GroupStatsCornerDurationsInner object, {
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
    if (object.durationSeconds != null) {
      yield r'durationSeconds';
      yield serializers.serialize(
        object.durationSeconds,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GroupStatsCornerDurationsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GroupStatsCornerDurationsInnerBuilder result,
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
        case r'durationSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.durationSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GroupStatsCornerDurationsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GroupStatsCornerDurationsInnerBuilder();
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

