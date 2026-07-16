// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/badge_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_badges_response.g.dart';

/// ExportBadgesResponse
///
/// Properties:
/// * [badges] 
@BuiltValue()
abstract class ExportBadgesResponse implements Built<ExportBadgesResponse, ExportBadgesResponseBuilder> {
  @BuiltValueField(wireName: r'badges')
  BuiltList<BadgeResponse>? get badges;

  ExportBadgesResponse._();

  factory ExportBadgesResponse([void updates(ExportBadgesResponseBuilder b)]) = _$ExportBadgesResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportBadgesResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportBadgesResponse> get serializer => _$ExportBadgesResponseSerializer();
}

class _$ExportBadgesResponseSerializer implements PrimitiveSerializer<ExportBadgesResponse> {
  @override
  final Iterable<Type> types = const [ExportBadgesResponse, _$ExportBadgesResponse];

  @override
  final String wireName = r'ExportBadgesResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportBadgesResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.badges != null) {
      yield r'badges';
      yield serializers.serialize(
        object.badges,
        specifiedType: const FullType(BuiltList, [FullType(BadgeResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportBadgesResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportBadgesResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'badges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BadgeResponse)]),
          ) as BuiltList<BadgeResponse>;
          result.badges.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportBadgesResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportBadgesResponseBuilder();
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
