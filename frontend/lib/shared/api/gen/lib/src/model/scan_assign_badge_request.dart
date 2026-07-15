// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'scan_assign_badge_request.g.dart';

/// ScanAssignBadgeRequest
///
/// Properties:
/// * [groupName] 
/// * [qrPayload] 
@BuiltValue()
abstract class ScanAssignBadgeRequest implements Built<ScanAssignBadgeRequest, ScanAssignBadgeRequestBuilder> {
  @BuiltValueField(wireName: r'groupName')
  String? get groupName;

  @BuiltValueField(wireName: r'qrPayload')
  String? get qrPayload;

  ScanAssignBadgeRequest._();

  factory ScanAssignBadgeRequest([void updates(ScanAssignBadgeRequestBuilder b)]) = _$ScanAssignBadgeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScanAssignBadgeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScanAssignBadgeRequest> get serializer => _$ScanAssignBadgeRequestSerializer();
}

class _$ScanAssignBadgeRequestSerializer implements PrimitiveSerializer<ScanAssignBadgeRequest> {
  @override
  final Iterable<Type> types = const [ScanAssignBadgeRequest, _$ScanAssignBadgeRequest];

  @override
  final String wireName = r'ScanAssignBadgeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScanAssignBadgeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.groupName != null) {
      yield r'groupName';
      yield serializers.serialize(
        object.groupName,
        specifiedType: const FullType(String),
      );
    }
    if (object.qrPayload != null) {
      yield r'qrPayload';
      yield serializers.serialize(
        object.qrPayload,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ScanAssignBadgeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScanAssignBadgeRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groupName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupName = valueDes;
          break;
        case r'qrPayload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrPayload = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScanAssignBadgeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScanAssignBadgeRequestBuilder();
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
