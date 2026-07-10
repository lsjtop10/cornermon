//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'broadcast_receipt.g.dart';

/// BroadcastReceipt
///
/// Properties:
/// * [trackId] 
/// * [trackNo] 
/// * [cornerName] 
/// * [isRead] 
/// * [readAt] 
@BuiltValue()
abstract class BroadcastReceipt implements Built<BroadcastReceipt, BroadcastReceiptBuilder> {
  @BuiltValueField(wireName: r'trackId')
  String get trackId;

  @BuiltValueField(wireName: r'trackNo')
  int? get trackNo;

  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'isRead')
  bool get isRead;

  @BuiltValueField(wireName: r'readAt')
  DateTime? get readAt;

  BroadcastReceipt._();

  factory BroadcastReceipt([void updates(BroadcastReceiptBuilder b)]) = _$BroadcastReceipt;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BroadcastReceiptBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BroadcastReceipt> get serializer => _$BroadcastReceiptSerializer();
}

class _$BroadcastReceiptSerializer implements PrimitiveSerializer<BroadcastReceipt> {
  @override
  final Iterable<Type> types = const [BroadcastReceipt, _$BroadcastReceipt];

  @override
  final String wireName = r'BroadcastReceipt';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BroadcastReceipt object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trackId';
    yield serializers.serialize(
      object.trackId,
      specifiedType: const FullType(String),
    );
    if (object.trackNo != null) {
      yield r'trackNo';
      yield serializers.serialize(
        object.trackNo,
        specifiedType: const FullType(int),
      );
    }
    if (object.cornerName != null) {
      yield r'cornerName';
      yield serializers.serialize(
        object.cornerName,
        specifiedType: const FullType(String),
      );
    }
    yield r'isRead';
    yield serializers.serialize(
      object.isRead,
      specifiedType: const FullType(bool),
    );
    if (object.readAt != null) {
      yield r'readAt';
      yield serializers.serialize(
        object.readAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BroadcastReceipt object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BroadcastReceiptBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trackId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trackId = valueDes;
          break;
        case r'trackNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackNo = valueDes;
          break;
        case r'cornerName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerName = valueDes;
          break;
        case r'isRead':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isRead = valueDes;
          break;
        case r'readAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BroadcastReceipt deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BroadcastReceiptBuilder();
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

