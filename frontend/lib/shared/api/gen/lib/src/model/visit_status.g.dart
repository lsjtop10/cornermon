// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VisitStatus _$IN_PROGRESS = const VisitStatus._('IN_PROGRESS');
const VisitStatus _$COMPLETED = const VisitStatus._('COMPLETED');

VisitStatus _$valueOf(String name) {
  switch (name) {
    case 'IN_PROGRESS':
      return _$IN_PROGRESS;
    case 'COMPLETED':
      return _$COMPLETED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VisitStatus> _$values = BuiltSet<VisitStatus>(
  const <VisitStatus>[_$IN_PROGRESS, _$COMPLETED],
);

class _$VisitStatusMeta {
  const _$VisitStatusMeta();
  VisitStatus get IN_PROGRESS => _$IN_PROGRESS;
  VisitStatus get COMPLETED => _$COMPLETED;
  VisitStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<VisitStatus> get values => _$values;
}

mixin _$VisitStatusMixin {
  // ignore: non_constant_identifier_names
  _$VisitStatusMeta get VisitStatus => const _$VisitStatusMeta();
}

Serializer<VisitStatus> _$visitStatusSerializer = _$VisitStatusSerializer();

class _$VisitStatusSerializer implements PrimitiveSerializer<VisitStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IN_PROGRESS': 'IN_PROGRESS',
    'COMPLETED': 'COMPLETED',
  };

  @override
  final Iterable<Type> types = const <Type>[VisitStatus];
  @override
  final String wireName = 'VisitStatus';

  @override
  Object serialize(
    Serializers serializers,
    VisitStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  VisitStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => VisitStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
