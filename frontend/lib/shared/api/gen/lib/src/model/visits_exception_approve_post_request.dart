//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'visits_exception_approve_post_request.g.dart';

/// VisitsExceptionApprovePostRequest
///
/// Properties:
/// * [groupId] 
/// * [cornerId] 
@BuiltValue()
abstract class VisitsExceptionApprovePostRequest implements Built<VisitsExceptionApprovePostRequest, VisitsExceptionApprovePostRequestBuilder> {
  @BuiltValueField(wireName: r'groupId')
  String get groupId;

  @BuiltValueField(wireName: r'cornerId')
  String get cornerId;

  VisitsExceptionApprovePostRequest._();

  factory VisitsExceptionApprovePostRequest([void updates(VisitsExceptionApprovePostRequestBuilder b)]) = _$VisitsExceptionApprovePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VisitsExceptionApprovePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VisitsExceptionApprovePostRequest> get serializer => _$VisitsExceptionApprovePostRequestSerializer();
}

class _$VisitsExceptionApprovePostRequestSerializer implements PrimitiveSerializer<VisitsExceptionApprovePostRequest> {
  @override
  final Iterable<Type> types = const [VisitsExceptionApprovePostRequest, _$VisitsExceptionApprovePostRequest];

  @override
  final String wireName = r'VisitsExceptionApprovePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VisitsExceptionApprovePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'groupId';
    yield serializers.serialize(
      object.groupId,
      specifiedType: const FullType(String),
    );
    yield r'cornerId';
    yield serializers.serialize(
      object.cornerId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VisitsExceptionApprovePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VisitsExceptionApprovePostRequestBuilder result,
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
        case r'cornerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VisitsExceptionApprovePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VisitsExceptionApprovePostRequestBuilder();
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

