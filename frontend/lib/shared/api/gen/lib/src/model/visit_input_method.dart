//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'visit_input_method.g.dart';

class VisitInputMethod extends EnumClass {

  @BuiltValueEnumConst(wireName: r'QR_SCAN')
  static const VisitInputMethod QR_SCAN = _$QR_SCAN;
  @BuiltValueEnumConst(wireName: r'MANUAL')
  static const VisitInputMethod MANUAL = _$MANUAL;

  static Serializer<VisitInputMethod> get serializer => _$visitInputMethodSerializer;

  const VisitInputMethod._(String name): super(name);

  static BuiltSet<VisitInputMethod> get values => _$values;
  static VisitInputMethod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class VisitInputMethodMixin = Object with _$VisitInputMethodMixin;

