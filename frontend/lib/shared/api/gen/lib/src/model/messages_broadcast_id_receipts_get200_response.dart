//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:cornermon_api_gen/src/model/broadcast_receipt.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'messages_broadcast_id_receipts_get200_response.g.dart';

/// MessagesBroadcastIdReceiptsGet200Response
///
/// Properties:
/// * [receipts] 
/// * [readRate] 
@BuiltValue()
abstract class MessagesBroadcastIdReceiptsGet200Response implements Built<MessagesBroadcastIdReceiptsGet200Response, MessagesBroadcastIdReceiptsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'receipts')
  BuiltList<BroadcastReceipt>? get receipts;

  @BuiltValueField(wireName: r'readRate')
  double? get readRate;

  MessagesBroadcastIdReceiptsGet200Response._();

  factory MessagesBroadcastIdReceiptsGet200Response([void updates(MessagesBroadcastIdReceiptsGet200ResponseBuilder b)]) = _$MessagesBroadcastIdReceiptsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessagesBroadcastIdReceiptsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessagesBroadcastIdReceiptsGet200Response> get serializer => _$MessagesBroadcastIdReceiptsGet200ResponseSerializer();
}

class _$MessagesBroadcastIdReceiptsGet200ResponseSerializer implements PrimitiveSerializer<MessagesBroadcastIdReceiptsGet200Response> {
  @override
  final Iterable<Type> types = const [MessagesBroadcastIdReceiptsGet200Response, _$MessagesBroadcastIdReceiptsGet200Response];

  @override
  final String wireName = r'MessagesBroadcastIdReceiptsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessagesBroadcastIdReceiptsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.receipts != null) {
      yield r'receipts';
      yield serializers.serialize(
        object.receipts,
        specifiedType: const FullType(BuiltList, [FullType(BroadcastReceipt)]),
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
    MessagesBroadcastIdReceiptsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessagesBroadcastIdReceiptsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'receipts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BroadcastReceipt)]),
          ) as BuiltList<BroadcastReceipt>;
          result.receipts.replace(valueDes);
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
  MessagesBroadcastIdReceiptsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessagesBroadcastIdReceiptsGet200ResponseBuilder();
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

