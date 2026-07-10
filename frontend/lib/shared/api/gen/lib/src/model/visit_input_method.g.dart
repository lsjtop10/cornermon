// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_input_method.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VisitInputMethod _$QR_SCAN = const VisitInputMethod._('QR_SCAN');
const VisitInputMethod _$MANUAL = const VisitInputMethod._('MANUAL');

VisitInputMethod _$valueOf(String name) {
  switch (name) {
    case 'QR_SCAN':
      return _$QR_SCAN;
    case 'MANUAL':
      return _$MANUAL;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VisitInputMethod> _$values = BuiltSet<VisitInputMethod>(
  const <VisitInputMethod>[_$QR_SCAN, _$MANUAL],
);

class _$VisitInputMethodMeta {
  const _$VisitInputMethodMeta();
  VisitInputMethod get QR_SCAN => _$QR_SCAN;
  VisitInputMethod get MANUAL => _$MANUAL;
  VisitInputMethod valueOf(String name) => _$valueOf(name);
  BuiltSet<VisitInputMethod> get values => _$values;
}

mixin _$VisitInputMethodMixin {
  // ignore: non_constant_identifier_names
  _$VisitInputMethodMeta get VisitInputMethod => const _$VisitInputMethodMeta();
}

Serializer<VisitInputMethod> _$visitInputMethodSerializer =
    _$VisitInputMethodSerializer();

class _$VisitInputMethodSerializer
    implements PrimitiveSerializer<VisitInputMethod> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'QR_SCAN': 'QR_SCAN',
    'MANUAL': 'MANUAL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'QR_SCAN': 'QR_SCAN',
    'MANUAL': 'MANUAL',
  };

  @override
  final Iterable<Type> types = const <Type>[VisitInputMethod];
  @override
  final String wireName = 'VisitInputMethod';

  @override
  Object serialize(
    Serializers serializers,
    VisitInputMethod object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  VisitInputMethod deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => VisitInputMethod.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
