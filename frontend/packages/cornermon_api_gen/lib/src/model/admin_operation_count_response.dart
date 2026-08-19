//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_operation_count_response.g.dart';

/// AdminOperationCountResponse
///
/// Properties:
/// * [adminId] 
/// * [adminName] 
/// * [count] 
@BuiltValue()
abstract class AdminOperationCountResponse implements Built<AdminOperationCountResponse, AdminOperationCountResponseBuilder> {
  @BuiltValueField(wireName: r'adminId')
  String? get adminId;

  @BuiltValueField(wireName: r'adminName')
  String? get adminName;

  @BuiltValueField(wireName: r'count')
  int? get count;

  AdminOperationCountResponse._();

  factory AdminOperationCountResponse([void updates(AdminOperationCountResponseBuilder b)]) = _$AdminOperationCountResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminOperationCountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminOperationCountResponse> get serializer => _$AdminOperationCountResponseSerializer();
}

class _$AdminOperationCountResponseSerializer implements PrimitiveSerializer<AdminOperationCountResponse> {
  @override
  final Iterable<Type> types = const [AdminOperationCountResponse, _$AdminOperationCountResponse];

  @override
  final String wireName = r'AdminOperationCountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminOperationCountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.adminId != null) {
      yield r'adminId';
      yield serializers.serialize(
        object.adminId,
        specifiedType: const FullType(String),
      );
    }
    if (object.adminName != null) {
      yield r'adminName';
      yield serializers.serialize(
        object.adminName,
        specifiedType: const FullType(String),
      );
    }
    if (object.count != null) {
      yield r'count';
      yield serializers.serialize(
        object.count,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminOperationCountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminOperationCountResponseBuilder result,
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
        case r'adminName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.adminName = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminOperationCountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminOperationCountResponseBuilder();
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

