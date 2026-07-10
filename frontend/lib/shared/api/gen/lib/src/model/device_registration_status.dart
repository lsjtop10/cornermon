//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_registration_status.g.dart';

class DeviceRegistrationStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PENDING')
  static const DeviceRegistrationStatus PENDING = _$PENDING;
  @BuiltValueEnumConst(wireName: r'APPROVED')
  static const DeviceRegistrationStatus APPROVED = _$APPROVED;
  @BuiltValueEnumConst(wireName: r'REJECTED')
  static const DeviceRegistrationStatus REJECTED = _$REJECTED;
  @BuiltValueEnumConst(wireName: r'REVOKED')
  static const DeviceRegistrationStatus REVOKED = _$REVOKED;

  static Serializer<DeviceRegistrationStatus> get serializer => _$deviceRegistrationStatusSerializer;

  const DeviceRegistrationStatus._(String name): super(name);

  static BuiltSet<DeviceRegistrationStatus> get values => _$values;
  static DeviceRegistrationStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DeviceRegistrationStatusMixin = Object with _$DeviceRegistrationStatusMixin;

