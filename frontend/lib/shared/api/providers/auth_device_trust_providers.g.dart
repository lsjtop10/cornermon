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
         retry: null,
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
    r'101cea731ed0c6c93a4b14751e0447fb03f4eb20';

final class RevokeAdminSessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  RevokeAdminSessionFamily._()
    : super(
        retry: null,
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
         retry: null,
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
    r'5fcd8ed7433286101d52af951fcb32c8173bb509';

final class ReleaseTrackLockoutFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  ReleaseTrackLockoutFamily._()
    : super(
        retry: null,
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
         retry: null,
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

String _$forceLogoutTrackHash() => r'b7db4bb052cf20a113a029ba475527086ea0ce5b';

final class ForceLogoutTrackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, TrackId> {
  ForceLogoutTrackFamily._()
    : super(
        retry: null,
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

String _$activeSessionListHash() => r'ac3e6bd1980d6451633ce6967a78bcfff62019de';

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
final deviceRegistrationListProvider = DeviceRegistrationListProvider._();

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
  DeviceRegistrationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRegistrationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRegistrationListHash();

  @$internal
  @override
  $FutureProviderElement<List<DeviceRegistration>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeviceRegistration>> create(Ref ref) {
    return deviceRegistrationList(ref);
  }
}

String _$deviceRegistrationListHash() =>
    r'32401c3b96cb7c8ff593804d29c619af87f06f31';

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

String _$lockedDeviceListHash() => r'29c7b066da197a453c168006e375dad846ed1c96';

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
    required DeviceRegistrationId super.argument,
  }) : super(
         retry: null,
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
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DeviceRegistration> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceRegistration> create(Ref ref) {
    final argument = this.argument as DeviceRegistrationId;
    return approveDeviceRegistration(ref, argument);
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
    r'83e05de70fd710e3d3f8cc337921336c70168527';

final class ApproveDeviceRegistrationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DeviceRegistration>,
          DeviceRegistrationId
        > {
  ApproveDeviceRegistrationFamily._()
    : super(
        retry: null,
        name: r'approveDeviceRegistrationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ApproveDeviceRegistrationProvider call(DeviceRegistrationId id) =>
      ApproveDeviceRegistrationProvider._(argument: id, from: this);

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
    required DeviceRegistrationId super.argument,
  }) : super(
         retry: null,
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
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DeviceRegistration> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceRegistration> create(Ref ref) {
    final argument = this.argument as DeviceRegistrationId;
    return rejectDeviceRegistration(ref, argument);
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
    r'10634698ed25350579fd9a5a4e566a1c6fefd6b1';

final class RejectDeviceRegistrationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DeviceRegistration>,
          DeviceRegistrationId
        > {
  RejectDeviceRegistrationFamily._()
    : super(
        retry: null,
        name: r'rejectDeviceRegistrationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RejectDeviceRegistrationProvider call(DeviceRegistrationId id) =>
      RejectDeviceRegistrationProvider._(argument: id, from: this);

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
    required DeviceRegistrationId super.argument,
  }) : super(
         retry: null,
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
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DeviceRegistration> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceRegistration> create(Ref ref) {
    final argument = this.argument as DeviceRegistrationId;
    return revokeDeviceRegistration(ref, argument);
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
    r'6a93b3dccd31320d87dfb4595e59ece1ea9dfb3b';

final class RevokeDeviceRegistrationFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<DeviceRegistration>,
          DeviceRegistrationId
        > {
  RevokeDeviceRegistrationFamily._()
    : super(
        retry: null,
        name: r'revokeDeviceRegistrationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RevokeDeviceRegistrationProvider call(DeviceRegistrationId id) =>
      RevokeDeviceRegistrationProvider._(argument: id, from: this);

  @override
  String toString() => r'revokeDeviceRegistrationProvider';
}
