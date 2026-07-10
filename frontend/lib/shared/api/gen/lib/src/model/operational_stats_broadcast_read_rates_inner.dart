//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operational_stats_broadcast_read_rates_inner.g.dart';

/// OperationalStatsBroadcastReadRatesInner
///
/// Properties:
/// * [messageId] 
/// * [content] 
/// * [readCount] 
/// * [totalTracks] 
/// * [readRate] 
@BuiltValue()
abstract class OperationalStatsBroadcastReadRatesInner implements Built<OperationalStatsBroadcastReadRatesInner, OperationalStatsBroadcastReadRatesInnerBuilder> {
  @BuiltValueField(wireName: r'messageId')
  String? get messageId;

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'readCount')
  int? get readCount;

  @BuiltValueField(wireName: r'totalTracks')
  int? get totalTracks;

  @BuiltValueField(wireName: r'readRate')
  double? get readRate;

  OperationalStatsBroadcastReadRatesInner._();

  factory OperationalStatsBroadcastReadRatesInner([void updates(OperationalStatsBroadcastReadRatesInnerBuilder b)]) = _$OperationalStatsBroadcastReadRatesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperationalStatsBroadcastReadRatesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperationalStatsBroadcastReadRatesInner> get serializer => _$OperationalStatsBroadcastReadRatesInnerSerializer();
}

class _$OperationalStatsBroadcastReadRatesInnerSerializer implements PrimitiveSerializer<OperationalStatsBroadcastReadRatesInner> {
  @override
  final Iterable<Type> types = const [OperationalStatsBroadcastReadRatesInner, _$OperationalStatsBroadcastReadRatesInner];

  @override
  final String wireName = r'OperationalStatsBroadcastReadRatesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperationalStatsBroadcastReadRatesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.messageId != null) {
      yield r'messageId';
      yield serializers.serialize(
        object.messageId,
        specifiedType: const FullType(String),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.readCount != null) {
      yield r'readCount';
      yield serializers.serialize(
        object.readCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalTracks != null) {
      yield r'totalTracks';
      yield serializers.serialize(
        object.totalTracks,
        specifiedType: const FullType(int),
      );
    }
    if (object.readRate != null) {
      yield r'readRate';
      yield serializers.serialize(
        object.readRate,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OperationalStatsBroadcastReadRatesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OperationalStatsBroadcastReadRatesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'messageId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.messageId = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'readCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.readCount = valueDes;
          break;
        case r'totalTracks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalTracks = valueDes;
          break;
        case r'readRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.readRate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperationalStatsBroadcastReadRatesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperationalStatsBroadcastReadRatesInnerBuilder();
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

