// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TrackStatus _$ACTIVE = const TrackStatus._('ACTIVE');
const TrackStatus _$DELETED = const TrackStatus._('DELETED');

TrackStatus _$valueOf(String name) {
  switch (name) {
    case 'ACTIVE':
      return _$ACTIVE;
    case 'DELETED':
      return _$DELETED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackStatus> _$values =
    BuiltSet<TrackStatus>(const <TrackStatus>[
  _$ACTIVE,
  _$DELETED,
]);

class _$TrackStatusMeta {
  const _$TrackStatusMeta();
  TrackStatus get ACTIVE => _$ACTIVE;
  TrackStatus get DELETED => _$DELETED;
  TrackStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<TrackStatus> get values => _$values;
}

abstract class _$TrackStatusMixin {
  // ignore: non_constant_identifier_names
  _$TrackStatusMeta get TrackStatus => const _$TrackStatusMeta();
}

Serializer<TrackStatus> _$trackStatusSerializer = _$TrackStatusSerializer();

class _$TrackStatusSerializer implements PrimitiveSerializer<TrackStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'DELETED': 'DELETED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'DELETED': 'DELETED',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackStatus];
  @override
  final String wireName = 'TrackStatus';

  @override
  Object serialize(Serializers serializers, TrackStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
