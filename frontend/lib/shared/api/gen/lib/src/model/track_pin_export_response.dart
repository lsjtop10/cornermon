// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'track_pin_export_response.g.dart';

/// TrackPINExportResponse
///
/// Properties:
/// * [cornerName] 
/// * [pin] 
/// * [trackNo] 
@BuiltValue()
abstract class TrackPINExportResponse implements Built<TrackPINExportResponse, TrackPINExportResponseBuilder> {
  @BuiltValueField(wireName: r'cornerName')
  String? get cornerName;

  @BuiltValueField(wireName: r'pin')
  String? get pin;

  @BuiltValueField(wireName: r'trackNo')
  int? get trackNo;

  TrackPINExportResponse._();

  factory TrackPINExportResponse([void updates(TrackPINExportResponseBuilder b)]) = _$TrackPINExportResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackPINExportResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackPINExportResponse> get serializer => _$TrackPINExportResponseSerializer();
}

class _$TrackPINExportResponseSerializer implements PrimitiveSerializer<TrackPINExportResponse> {
  @override
  final Iterable<Type> types = const [TrackPINExportResponse, _$TrackPINExportResponse];

  @override
  final String wireName = r'TrackPINExportResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackPINExportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cornerName != null) {
      yield r'cornerName';
      yield serializers.serialize(
        object.cornerName,
        specifiedType: const FullType(String),
      );
    }
    if (object.pin != null) {
      yield r'pin';
      yield serializers.serialize(
        object.pin,
        specifiedType: const FullType(String),
      );
    }
    if (object.trackNo != null) {
      yield r'trackNo';
      yield serializers.serialize(
        object.trackNo,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackPINExportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackPINExportResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cornerName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cornerName = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        case r'trackNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trackNo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackPINExportResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackPINExportResponseBuilder();
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
