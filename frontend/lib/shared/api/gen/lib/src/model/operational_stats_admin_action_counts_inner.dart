//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operational_stats_admin_action_counts_inner.g.dart';

/// OperationalStatsAdminActionCountsInner
///
/// Properties:
/// * [adminId] 
/// * [actionCount] 
@BuiltValue()
abstract class OperationalStatsAdminActionCountsInner implements Built<OperationalStatsAdminActionCountsInner, OperationalStatsAdminActionCountsInnerBuilder> {
  @BuiltValueField(wireName: r'adminId')
  String? get adminId;

  @BuiltValueField(wireName: r'actionCount')
  int? get actionCount;

  OperationalStatsAdminActionCountsInner._();

  factory OperationalStatsAdminActionCountsInner([void updates(OperationalStatsAdminActionCountsInnerBuilder b)]) = _$OperationalStatsAdminActionCountsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperationalStatsAdminActionCountsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperationalStatsAdminActionCountsInner> get serializer => _$OperationalStatsAdminActionCountsInnerSerializer();
}

class _$OperationalStatsAdminActionCountsInnerSerializer implements PrimitiveSerializer<OperationalStatsAdminActionCountsInner> {
  @override
  final Iterable<Type> types = const [OperationalStatsAdminActionCountsInner, _$OperationalStatsAdminActionCountsInner];

  @override
  final String wireName = r'OperationalStatsAdminActionCountsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperationalStatsAdminActionCountsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.adminId != null) {
      yield r'adminId';
      yield serializers.serialize(
        object.adminId,
        specifiedType: const FullType(String),
      );
    }
    if (object.actionCount != null) {
      yield r'actionCount';
      yield serializers.serialize(
        object.actionCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OperationalStatsAdminActionCountsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OperationalStatsAdminActionCountsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'adminId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.adminId = valueDes;
          break;
        case r'actionCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.actionCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperationalStatsAdminActionCountsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperationalStatsAdminActionCountsInnerBuilder();
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

