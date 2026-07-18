// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_device_trust_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authDeviceTrustApi)
final authDeviceTrustApiProvider = AuthDeviceTrustApiProvider._();

final class AuthDeviceTrustApiProvider
    extends
        $FunctionalProvider<
          AAuthDeviceTrustApi,
          AAuthDeviceTrustApi,
          AAuthDeviceTrustApi
        >
    with $Provider<AAuthDeviceTrustApi> {
  AuthDeviceTrustApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authDeviceTrustApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authDeviceTrustApiHash();

  @$internal
  @override
  $ProviderElement<AAuthDeviceTrustApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AAuthDeviceTrustApi create(Ref ref) {
    return authDeviceTrustApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AAuthDeviceTrustApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AAuthDeviceTrustApi>(value),
    );
  }
}

String _$authDeviceTrustApiHash() =>
    r'21e0c964144f0566a278a09d7a8141ec4c066062';

@ProviderFor(adminLogin)
final adminLoginProvider = AdminLoginFamily._();

final class AdminLoginProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminLoginResponse>,
          AdminLoginResponse,
          FutureOr<AdminLoginResponse>
        >
    with
        $FutureModifier<AdminLoginResponse>,
        $FutureProvider<AdminLoginResponse> {
  AdminLoginProvider._({
    required AdminLoginFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: noRetry,
         name: r'adminLoginProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminLoginHash();

  @override
  String toString() {
    return r'adminLoginProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<AdminLoginResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminLoginResponse> create(Ref ref) {
    final argument = this.argument as (String, String);
    return adminLogin(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminLoginProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminLoginHash() => r'ff467d0e37b70329de45c96ded536b0eef3085fa';

final class AdminLoginFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<AdminLoginResponse>,
          (String, String)
        > {
  AdminLoginFamily._()
    : super(
        retry: noRetry,
        name: r'adminLoginProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminLoginProvider call(String id, String password) =>
      AdminLoginProvider._(argument: (id, password), from: this);

  @override
  String toString() => r'adminLoginProvider';
}

@ProviderFor(adminLogout)
final adminLogoutProvider = AdminLogoutProvider._();

final class AdminLogoutProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  AdminLogoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: noRetry,
        name: r'adminLogoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminLogoutHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return adminLogout(ref);
  }
}

String _$adminLogoutHash() => r'581075dbca3f7720c54b47388cb1b8ffedcee6dd';

@ProviderFor(adminSessionList)
final adminSessionListProvider = AdminSessionListProvider._();

final class AdminSessionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AdminSession>>,
          List<AdminSession>,
          FutureOr<List<AdminSession>>
        >
    with
        $FutureModifier<List<AdminSession>>,
        $FutureProvider<List<AdminSession>> {
  AdminSessionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminSessionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminSessionListHash();

  @$internal
  @override
  $FutureProviderElement<List<AdminSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AdminSession>> create(Ref ref) {
    return adminSessionList(ref);
  }
}

String _$adminSessionListHash() => r'645e87b92a08ae0f93c6a84cf6fca8fcd1144a6d';

@ProviderFor(revokeAdminSession)
final revokeAdminSessionProvider = RevokeAdminSessionFamily._();

final class RevokeAdminSessionProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RevokeAdminSessionProvider._({
    required RevokeAdminSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: noRetry,
         name: r'revokeAdminSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$revokeAdminSessionHash();

  @override
  String toString() {
    return r'revokeAdminSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return revokeAdminSession(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RevokeAdminSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$revokeAdminSessionHash() =>
    r'cebb124ebcf1dbaa5224dd6a2cc8ed7b08730fbc';

final class RevokeAdminSessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  RevokeAdminSessionFamily._()
    : super(
        retry: noRetry,
        name: r'revokeAdminSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RevokeAdminSessionProvider call(String sessionId) =>
      RevokeAdminSessionProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'revokeAdminSessionProvider';
}

@ProviderFor(releaseTrackLockout)
final releaseTrackLockoutProvider = ReleaseTrackLockoutFamily._();

final class ReleaseTrackLockoutProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  ReleaseTrackLockoutProvider._({
    required ReleaseTrackLockoutFamily super.from,
    required String super.argument,
  }) : super(
         retry: noRetry,
         name: r'releaseTrackLockoutProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$releaseTrackLockoutHash();

  @override
  String toString() {
    return r'releaseTrackLockoutProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return releaseTrackLockout(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReleaseTrackLockoutProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$releaseTrackLockoutHash() =>
    r'03faf03f946e7938fa365aa4da5d5e655f1f7490';

final class ReleaseTrackLockoutFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  ReleaseTrackLockoutFamily._()
    : super(
        retry: noRetry,
        name: r'releaseTrackLockoutProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReleaseTrackLockoutProvider call(String deviceId) =>
      ReleaseTrackLockoutProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'releaseTrackLockoutProvider';
}

@ProviderFor(forceLogoutTrack)
final forceLogoutTrackProvider = ForceLogoutTrackFamily._();

final class ForceLogoutTrackProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  ForceLogoutTrackProvider._({
    required ForceLogoutTrackFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: noRetry,
         name: r'forceLogoutTrackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$forceLogoutTrackHash();

  @override
  String toString() {
    return r'forceLogoutTrackProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as TrackId;
    return forceLogoutTrack(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ForceLogoutTrackProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$forceLogoutTrackHash() => r'ea47c4be1716db98029ac9d61607f04db97832e7';

final class ForceLogoutTrackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, TrackId> {
  ForceLogoutTrackFamily._()
    : super(
        retry: noRetry,
        name: r'forceLogoutTrackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ForceLogoutTrackProvider call(TrackId trackId) =>
      ForceLogoutTrackProvider._(argument: trackId, from: this);

  @override
  String toString() => r'forceLogoutTrackProvider';
}

@ProviderFor(activeSessionList)
final activeSessionListProvider = ActiveSessionListFamily._();

final class ActiveSessionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FacilitatorSession>>,
          List<FacilitatorSession>,
          FutureOr<List<FacilitatorSession>>
        >
    with
        $FutureModifier<List<FacilitatorSession>>,
        $FutureProvider<List<FacilitatorSession>> {
  ActiveSessionListProvider._({
    required ActiveSessionListFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'activeSessionListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeSessionListHash();

  @override
  String toString() {
    return r'activeSessionListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FacilitatorSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FacilitatorSession>> create(Ref ref) {
    final argument = this.argument as CampId;
    return activeSessionList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveSessionListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeSessionListHash() => r'51c274dd215bf481eeab2654a662cab4adbe33d5';

final class ActiveSessionListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FacilitatorSession>>, CampId> {
  ActiveSessionListFamily._()
    : super(
        retry: null,
        name: r'activeSessionListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ActiveSessionListProvider call(CampId campId) =>
      ActiveSessionListProvider._(argument: campId, from: this);

  @override
  String toString() => r'activeSessionListProvider';
}

@ProviderFor(deviceRegistrationList)
final deviceRegistrationListProvider = DeviceRegistrationListFamily._();

final class DeviceRegistrationListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceRegistration>>,
          List<DeviceRegistration>,
          FutureOr<List<DeviceRegistration>>
        >
    with
        $FutureModifier<List<DeviceRegistration>>,
        $FutureProvider<List<DeviceRegistration>> {
  DeviceRegistrationListProvider._({
    required DeviceRegistrationListFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'deviceRegistrationListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deviceRegistrationListHash();

  @override
  String toString() {
    return r'deviceRegistrationListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DeviceRegistration>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeviceRegistration>> create(Ref ref) {
    final argument = this.argument as CampId;
    return deviceRegistrationList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceRegistrationListProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deviceRegistrationListHash() =>
    r'6e3ee0761c394dbffb1839bd65f411bcd372317c';

final class DeviceRegistrationListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DeviceRegistration>>, CampId> {
  DeviceRegistrationListFamily._()
    : super(
        retry: null,
        name: r'deviceRegistrationListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeviceRegistrationListProvider call(CampId campId) =>
      DeviceRegistrationListProvider._(argument: campId, from: this);

  @override
  String toString() => r'deviceRegistrationListProvider';
}

@ProviderFor(lockedDeviceList)
final lockedDeviceListProvider = LockedDeviceListFamily._();

final class LockedDeviceListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceRegistration>>,
          List<DeviceRegistration>,
          FutureOr<List<DeviceRegistration>>
        >
    with
        $FutureModifier<List<DeviceRegistration>>,
        $FutureProvider<List<DeviceRegistration>> {
  LockedDeviceListProvider._({
    required LockedDeviceListFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'lockedDeviceListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lockedDeviceListHash();

  @override
  String toString() {
    return r'lockedDeviceListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DeviceRegistration>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeviceRegistration>> create(Ref ref) {
    final argument = this.argument as CampId;
    return lockedDeviceList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LockedDeviceListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lockedDeviceListHash() => r'2383f1aeaa1ed422dec44bc8fccc6f933fc4c770';

final class LockedDeviceListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DeviceRegistration>>, CampId> {
  LockedDeviceListFamily._()
    : super(
        retry: null,
        name: r'lockedDeviceListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LockedDeviceListProvider call(CampId campId) =>
      LockedDeviceListProvider._(argument: campId, from: this);

  @override
  String toString() => r'lockedDeviceListProvider';
}

@ProviderFor(approveDeviceRegistration)
final approveDeviceRegistrationProvider = ApproveDeviceRegistrationFamily._();

final class ApproveDeviceRegistrationProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceRegistration>,
          DeviceRegistration,
          FutureOr<DeviceRegistration>
        >
    with
        $FutureModifier<DeviceRegistration>,
        $FutureProvider<DeviceRegistration> {
  ApproveDeviceRegistrationProvider._({
    required ApproveDeviceRegistrationFamily super.from,
    required (CampId, DeviceRegistrationId) super.argument,
  }) : super(
         retry: noRetry,
         name: r'approveDeviceRegistrationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$approveDeviceRegistrationHash();

  @override
  String toString() {
    return r'approveDeviceRegistrationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DeviceRegistration> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceRegistration> create(Ref ref) {
    final argument = this.argument as (CampId, DeviceRegistrationId);
    return approveDeviceRegistration(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ApproveDeviceRegistrationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$approveDeviceRegistrationHash() =>
    r'4af6564ecd4d513123070a4241bb5e74c93de6b7';

final class ApproveDeviceRegistrationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DeviceRegistration>,
          (CampId, DeviceRegistrationId)
        > {
  ApproveDeviceRegistrationFamily._()
    : super(
        retry: noRetry,
        name: r'approveDeviceRegistrationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ApproveDeviceRegistrationProvider call(
    CampId campId,
    DeviceRegistrationId id,
  ) => ApproveDeviceRegistrationProvider._(argument: (campId, id), from: this);

  @override
  String toString() => r'approveDeviceRegistrationProvider';
}

@ProviderFor(rejectDeviceRegistration)
final rejectDeviceRegistrationProvider = RejectDeviceRegistrationFamily._();

final class RejectDeviceRegistrationProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceRegistration>,
          DeviceRegistration,
          FutureOr<DeviceRegistration>
        >
    with
        $FutureModifier<DeviceRegistration>,
        $FutureProvider<DeviceRegistration> {
  RejectDeviceRegistrationProvider._({
    required RejectDeviceRegistrationFamily super.from,
    required (CampId, DeviceRegistrationId) super.argument,
  }) : super(
         retry: noRetry,
         name: r'rejectDeviceRegistrationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rejectDeviceRegistrationHash();

  @override
  String toString() {
    return r'rejectDeviceRegistrationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DeviceRegistration> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceRegistration> create(Ref ref) {
    final argument = this.argument as (CampId, DeviceRegistrationId);
    return rejectDeviceRegistration(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RejectDeviceRegistrationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rejectDeviceRegistrationHash() =>
    r'85766a0e066cf69b1db501e56d3262571c37ebc1';

final class RejectDeviceRegistrationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DeviceRegistration>,
          (CampId, DeviceRegistrationId)
        > {
  RejectDeviceRegistrationFamily._()
    : super(
        retry: noRetry,
        name: r'rejectDeviceRegistrationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RejectDeviceRegistrationProvider call(
    CampId campId,
    DeviceRegistrationId id,
  ) => RejectDeviceRegistrationProvider._(argument: (campId, id), from: this);

  @override
  String toString() => r'rejectDeviceRegistrationProvider';
}

@ProviderFor(revokeDeviceRegistration)
final revokeDeviceRegistrationProvider = RevokeDeviceRegistrationFamily._();

final class RevokeDeviceRegistrationProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceRegistration>,
          DeviceRegistration,
          FutureOr<DeviceRegistration>
        >
    with
        $FutureModifier<DeviceRegistration>,
        $FutureProvider<DeviceRegistration> {
  RevokeDeviceRegistrationProvider._({
    required RevokeDeviceRegistrationFamily super.from,
    required (CampId, DeviceRegistrationId) super.argument,
  }) : super(
         retry: noRetry,
         name: r'revokeDeviceRegistrationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$revokeDeviceRegistrationHash();

  @override
  String toString() {
    return r'revokeDeviceRegistrationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DeviceRegistration> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceRegistration> create(Ref ref) {
    final argument = this.argument as (CampId, DeviceRegistrationId);
    return revokeDeviceRegistration(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RevokeDeviceRegistrationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$revokeDeviceRegistrationHash() =>
    r'c4b5d07aa6cbebe1d0b55e81ef28bd238f260156';

final class RevokeDeviceRegistrationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DeviceRegistration>,
          (CampId, DeviceRegistrationId)
        > {
  RevokeDeviceRegistrationFamily._()
    : super(
        retry: noRetry,
        name: r'revokeDeviceRegistrationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RevokeDeviceRegistrationProvider call(
    CampId campId,
    DeviceRegistrationId id,
  ) => RevokeDeviceRegistrationProvider._(argument: (campId, id), from: this);

  @override
  String toString() => r'revokeDeviceRegistrationProvider';
}
