//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/visit_status_per_corner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'corner_progress.g.dart';

/// CornerProgress
///
/// Properties:
/// * [cornerId] 
/// * [cornerName] 
/// * [status] 
@BuiltValue()
abstract class CornerProgress implements Built<CornerProgress, CornerProgressBuilder> {
  @BuiltValueField(wireName: r'cornerId')
  String get cornerId;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'status')
  VisitStatusPerCorner get status;
  // enum statusEnum {  NOT_VISITED,  IN_PROGRESS,  COMPLETED,  };

  CornerProgress._();

  factory CornerProgress([void updates(CornerProgressBuilder b)]) = _$CornerProgress;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CornerProgressBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CornerProgress> get serializer => _$CornerProgressSerializer();
}

class _$CornerProgressSerializer implements PrimitiveSerializer<CornerProgress> {
  @override
  final Iterable<Type> types = const [CornerProgress, _$CornerProgress];

  @override
  final String wireName = r'CornerProgress';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CornerProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cornerId';
    yield serializers.serialize(
      object.cornerId,
      specifiedType: const FullType(String),
    );
    if (object.cornerName != null) {
      yield r'cornerName';
      yield serializers.serialize(
        object.cornerName,
        specifiedType: const FullType(String),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(VisitStatusPerCorner),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CornerProgress object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CornerProgressBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VisitStatusPerCorner),
          ) as VisitStatusPerCorner;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CornerProgress deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CornerProgressBuilder();
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

