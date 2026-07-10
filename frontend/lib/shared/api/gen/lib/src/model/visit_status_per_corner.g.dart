// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_status_per_corner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VisitStatusPerCorner _$NOT_VISITED =
    const VisitStatusPerCorner._('NOT_VISITED');
const VisitStatusPerCorner _$IN_PROGRESS =
    const VisitStatusPerCorner._('IN_PROGRESS');
const VisitStatusPerCorner _$COMPLETED =
    const VisitStatusPerCorner._('COMPLETED');

VisitStatusPerCorner _$valueOf(String name) {
  switch (name) {
    case 'NOT_VISITED':
      return _$NOT_VISITED;
    case 'IN_PROGRESS':
      return _$IN_PROGRESS;
    case 'COMPLETED':
      return _$COMPLETED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VisitStatusPerCorner> _$values =
    BuiltSet<VisitStatusPerCorner>(const <VisitStatusPerCorner>[
  _$NOT_VISITED,
  _$IN_PROGRESS,
  _$COMPLETED,
]);

class _$VisitStatusPerCornerMeta {
  const _$VisitStatusPerCornerMeta();
  VisitStatusPerCorner get NOT_VISITED => _$NOT_VISITED;
  VisitStatusPerCorner get IN_PROGRESS => _$IN_PROGRESS;
  VisitStatusPerCorner get COMPLETED => _$COMPLETED;
  VisitStatusPerCorner valueOf(String name) => _$valueOf(name);
  BuiltSet<VisitStatusPerCorner> get values => _$values;
}

abstract class _$VisitStatusPerCornerMixin {
  // ignore: non_constant_identifier_names
  _$VisitStatusPerCornerMeta get VisitStatusPerCorner =>
      const _$VisitStatusPerCornerMeta();
}

Serializer<VisitStatusPerCorner> _$visitStatusPerCornerSerializer =
    _$VisitStatusPerCornerSerializer();

class _$VisitStatusPerCornerSerializer
    implements PrimitiveSerializer<VisitStatusPerCorner> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'NOT_VISITED': 'NOT_VISITED',
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'NOT_VISITED': 'NOT_VISITED',
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };

  @override
  final Iterable<Type> types = const <Type>[VisitStatusPerCorner];
  @override
  final String wireName = 'VisitStatusPerCorner';

  @override
  Object serialize(Serializers serializers, VisitStatusPerCorner object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VisitStatusPerCorner deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VisitStatusPerCorner.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
