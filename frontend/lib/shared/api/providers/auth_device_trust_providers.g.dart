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
    r'449aed9864dc440caed137139e4054035540b5ba';
