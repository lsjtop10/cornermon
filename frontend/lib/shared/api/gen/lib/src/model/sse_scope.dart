// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sse_scope.g.dart';

/// SSEScope
///
/// Properties:
/// * [kind] 
/// * [trackId] 
@BuiltValue()
abstract class SSEScope implements Built<SSEScope, SSEScopeBuilder> {
  @BuiltValueField(wireName: r'kind')
  SSEScopeKindEnum? get kind;
  // enum kindEnum {  camp,  track,  };

  @BuiltValueField(wireName: r'trackId')
  String? get trackId;

  SSEScope._();

  factory SSEScope([void updates(SSEScopeBuilder b)]) = _$SSEScope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SSEScopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SSEScope> get serializer => _$SSEScopeSerializer();
}

class _$SSEScopeSerializer implements PrimitiveSerializer<SSEScope> {
  @override
  final Iterable<Type> types = const [SSEScope, _$SSEScope];

  @override
  final String wireName = r'SSEScope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SSEScope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(SSEScopeKindEnum),
      );
    }
    if (object.trackId != null) {
      yield r'trackId';
      yield serializers.serialize(
        object.trackId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SSEScope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SSEScopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SSEScopeKindEnum),
          ) as SSEScopeKindEnum;
          result.kind = valueDes;
          break;
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SSEScope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SSEScopeBuilder();
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

class SSEScopeKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'camp')
  static const SSEScopeKindEnum camp = _$sSEScopeKindEnum_camp;
  @BuiltValueEnumConst(wireName: r'track')
  static const SSEScopeKindEnum track = _$sSEScopeKindEnum_track;

  static Serializer<SSEScopeKindEnum> get serializer => _$sSEScopeKindEnumSerializer;

  const SSEScopeKindEnum._(String name): super(name);

  static BuiltSet<SSEScopeKindEnum> get values => _$sSEScopeKindEnumValues;
  static SSEScopeKindEnum valueOf(String name) => _$sSEScopeKindEnumValueOf(name);
}
