//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:cornermon_api_gen/src/model/track_pin_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_tracks_response.g.dart';

/// ExportTracksResponse
///
/// Properties:
/// * [tracks] 
@BuiltValue()
abstract class ExportTracksResponse implements Built<ExportTracksResponse, ExportTracksResponseBuilder> {
  @BuiltValueField(wireName: r'tracks')
  BuiltList<TrackPinResponse>? get tracks;

  ExportTracksResponse._();

  factory ExportTracksResponse([void updates(ExportTracksResponseBuilder b)]) = _$ExportTracksResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportTracksResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportTracksResponse> get serializer => _$ExportTracksResponseSerializer();
}

class _$ExportTracksResponseSerializer implements PrimitiveSerializer<ExportTracksResponse> {
  @override
  final Iterable<Type> types = const [ExportTracksResponse, _$ExportTracksResponse];

  @override
  final String wireName = r'ExportTracksResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportTracksResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tracks != null) {
      yield r'tracks';
      yield serializers.serialize(
        object.tracks,
        specifiedType: const FullType(BuiltList, [FullType(TrackPinResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportTracksResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportTracksResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tracks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackPinResponse)]),
          ) as BuiltList<TrackPinResponse>;
          result.tracks.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportTracksResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportTracksResponseBuilder();
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

