//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/group.dart';
import 'package:cornermon_api_gen/src/model/corner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_sse_snapshot.g.dart';

/// 관리자 SSE 최초/재연결 시 전송되는 전체 스냅샷
///
/// Properties:
/// * [corners] 
/// * [groups] 
/// * [unreadBroadcastCount] 
@BuiltValue()
abstract class AdminSseSnapshot implements Built<AdminSseSnapshot, AdminSseSnapshotBuilder> {
  @BuiltValueField(wireName: r'corners')
  BuiltList<Corner>? get corners;

  @BuiltValueField(wireName: r'groups')
  BuiltList<Group>? get groups;

  @BuiltValueField(wireName: r'unreadBroadcastCount')
  int? get unreadBroadcastCount;

  AdminSseSnapshot._();

  factory AdminSseSnapshot([void updates(AdminSseSnapshotBuilder b)]) = _$AdminSseSnapshot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminSseSnapshotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminSseSnapshot> get serializer => _$AdminSseSnapshotSerializer();
}

class _$AdminSseSnapshotSerializer implements PrimitiveSerializer<AdminSseSnapshot> {
  @override
  final Iterable<Type> types = const [AdminSseSnapshot, _$AdminSseSnapshot];

  @override
  final String wireName = r'AdminSseSnapshot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminSseSnapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.corners != null) {
      yield r'corners';
      yield serializers.serialize(
        object.corners,
        specifiedType: const FullType(BuiltList, [FullType(Corner)]),
      );
    }
    if (object.groups != null) {
      yield r'groups';
      yield serializers.serialize(
        object.groups,
        specifiedType: const FullType(BuiltList, [FullType(Group)]),
      );
    }
    if (object.unreadBroadcastCount != null) {
      yield r'unreadBroadcastCount';
      yield serializers.serialize(
        object.unreadBroadcastCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminSseSnapshot object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminSseSnapshotBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'corners':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Corner)]),
          ) as BuiltList<Corner>;
          result.corners.replace(valueDes);
          break;
        case r'groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Group)]),
          ) as BuiltList<Group>;
          result.groups.replace(valueDes);
          break;
        case r'unreadBroadcastCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unreadBroadcastCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminSseSnapshot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminSseSnapshotBuilder();
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

