//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/badge.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'badges_bulk_generate_post201_response.g.dart';

/// BadgesBulkGeneratePost201Response
///
/// Properties:
/// * [badges] 
/// * [generatedCount] 
@BuiltValue()
abstract class BadgesBulkGeneratePost201Response implements Built<BadgesBulkGeneratePost201Response, BadgesBulkGeneratePost201ResponseBuilder> {
  @BuiltValueField(wireName: r'badges')
  BuiltList<Badge>? get badges;

  @BuiltValueField(wireName: r'generatedCount')
  int? get generatedCount;

  BadgesBulkGeneratePost201Response._();

  factory BadgesBulkGeneratePost201Response([void updates(BadgesBulkGeneratePost201ResponseBuilder b)]) = _$BadgesBulkGeneratePost201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadgesBulkGeneratePost201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BadgesBulkGeneratePost201Response> get serializer => _$BadgesBulkGeneratePost201ResponseSerializer();
}

class _$BadgesBulkGeneratePost201ResponseSerializer implements PrimitiveSerializer<BadgesBulkGeneratePost201Response> {
  @override
  final Iterable<Type> types = const [BadgesBulkGeneratePost201Response, _$BadgesBulkGeneratePost201Response];

  @override
  final String wireName = r'BadgesBulkGeneratePost201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BadgesBulkGeneratePost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.badges != null) {
      yield r'badges';
      yield serializers.serialize(
        object.badges,
        specifiedType: const FullType(BuiltList, [FullType(Badge)]),
      );
    }
    if (object.generatedCount != null) {
      yield r'generatedCount';
      yield serializers.serialize(
        object.generatedCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BadgesBulkGeneratePost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadgesBulkGeneratePost201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'badges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Badge)]),
          ) as BuiltList<Badge>;
          result.badges.replace(valueDes);
          break;
        case r'generatedCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generatedCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BadgesBulkGeneratePost201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadgesBulkGeneratePost201ResponseBuilder();
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

