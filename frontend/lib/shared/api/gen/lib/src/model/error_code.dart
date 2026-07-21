// @dart=2.18
//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_code.g.dart';

class ErrorCode extends EnumClass {

  @BuiltValueEnumConst(wireName: r'BADGE_ALREADY_ASSIGNED')
  static const ErrorCode CodeBadgeAlreadyAssigned = _$CodeBadgeAlreadyAssigned;
  @BuiltValueEnumConst(wireName: r'BADGE_NOT_ASSIGNED')
  static const ErrorCode CodeBadgeNotAssigned = _$CodeBadgeNotAssigned;
  @BuiltValueEnumConst(wireName: r'BADGE_NOT_FOUND')
  static const ErrorCode CodeBadgeNotFound = _$CodeBadgeNotFound;
  @BuiltValueEnumConst(wireName: r'BAD_REQUEST')
  static const ErrorCode CodeBadRequest = _$CodeBadRequest;
  @BuiltValueEnumConst(wireName: r'CAMP_INVALID_SETTINGS')
  static const ErrorCode CodeCampInvalidSettings = _$CodeCampInvalidSettings;
  @BuiltValueEnumConst(wireName: r'CAMP_NOT_ACTIVE')
  static const ErrorCode CodeCampNotActive = _$CodeCampNotActive;
  @BuiltValueEnumConst(wireName: r'CAMP_NOT_AVAILABLE')
  static const ErrorCode CodeCampNotAvailable = _$CodeCampNotAvailable;
  @BuiltValueEnumConst(wireName: r'CAMP_NOT_ENDED')
  static const ErrorCode CodeCampNotEnded = _$CodeCampNotEnded;
  @BuiltValueEnumConst(wireName: r'CAMP_NOT_FOUND')
  static const ErrorCode CodeCampNotFound = _$CodeCampNotFound;
  @BuiltValueEnumConst(wireName: r'CAMP_SETTINGS_LOCKED')
  static const ErrorCode CodeCampSettingsLocked = _$CodeCampSettingsLocked;
  @BuiltValueEnumConst(wireName: r'CAMP_STATE_CONFLICT')
  static const ErrorCode CodeCampStateConflict = _$CodeCampStateConflict;
  @BuiltValueEnumConst(wireName: r'CONFLICT')
  static const ErrorCode CodeConflict = _$CodeConflict;
  @BuiltValueEnumConst(wireName: r'CORNER_NOT_FOUND')
  static const ErrorCode CodeCornerNotFound = _$CodeCornerNotFound;
  @BuiltValueEnumConst(wireName: r'DEVICE_INVALID_TRANSITION')
  static const ErrorCode CodeDeviceInvalidTransition = _$CodeDeviceInvalidTransition;
  @BuiltValueEnumConst(wireName: r'DEVICE_LOCKED')
  static const ErrorCode CodeDeviceLocked = _$CodeDeviceLocked;
  @BuiltValueEnumConst(wireName: r'DEVICE_NOT_APPROVED')
  static const ErrorCode CodeDeviceNotApproved = _$CodeDeviceNotApproved;
  @BuiltValueEnumConst(wireName: r'FORBIDDEN')
  static const ErrorCode CodeForbidden = _$CodeForbidden;
  @BuiltValueEnumConst(wireName: r'GROUP_NOT_FOUND')
  static const ErrorCode CodeGroupNotFound = _$CodeGroupNotFound;
  @BuiltValueEnumConst(wireName: r'HTTP_ERROR')
  static const ErrorCode CodeHTTPError = _$CodeHTTPError;
  @BuiltValueEnumConst(wireName: r'INTERNAL_ERROR')
  static const ErrorCode CodeInternalError = _$CodeInternalError;
  @BuiltValueEnumConst(wireName: r'INTERNAL_SERVER_ERROR')
  static const ErrorCode CodeInternalServerError = _$CodeInternalServerError;
  @BuiltValueEnumConst(wireName: r'INVALID_PIN')
  static const ErrorCode CodeInvalidPin = _$CodeInvalidPin;
  @BuiltValueEnumConst(wireName: r'INVALID_TRANSITION')
  static const ErrorCode CodeInvalidTransition = _$CodeInvalidTransition;
  @BuiltValueEnumConst(wireName: r'ITINERARY_CONFLICT')
  static const ErrorCode CodeItineraryConflict = _$CodeItineraryConflict;
  @BuiltValueEnumConst(wireName: r'NOT_FOUND')
  static const ErrorCode CodeNotFound = _$CodeNotFound;
  @BuiltValueEnumConst(wireName: r'SESSION_REVOKED')
  static const ErrorCode CodeSessionRevoked = _$CodeSessionRevoked;
  @BuiltValueEnumConst(wireName: r'TRACK_BUSY')
  static const ErrorCode CodeTrackBusy = _$CodeTrackBusy;
  @BuiltValueEnumConst(wireName: r'TRACK_CONFLICT')
  static const ErrorCode CodeTrackConflict = _$CodeTrackConflict;
  @BuiltValueEnumConst(wireName: r'TRACK_NOT_ACTIVE')
  static const ErrorCode CodeTrackNotActive = _$CodeTrackNotActive;
  @BuiltValueEnumConst(wireName: r'TRACK_NOT_BUSY')
  static const ErrorCode CodeTrackNotBusy = _$CodeTrackNotBusy;
  @BuiltValueEnumConst(wireName: r'TRACK_NOT_FOUND')
  static const ErrorCode CodeTrackNotFound = _$CodeTrackNotFound;
  @BuiltValueEnumConst(wireName: r'TRACK_SCOPE_FORBIDDEN')
  static const ErrorCode CodeTrackScopeForbidden = _$CodeTrackScopeForbidden;
  @BuiltValueEnumConst(wireName: r'UNAUTHORIZED')
  static const ErrorCode CodeUnauthorized = _$CodeUnauthorized;

  static Serializer<ErrorCode> get serializer => _$errorCodeSerializer;

  const ErrorCode._(String name): super(name);

  static BuiltSet<ErrorCode> get values => _$values;
  static ErrorCode valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ErrorCodeMixin = Object with _$ErrorCodeMixin;
