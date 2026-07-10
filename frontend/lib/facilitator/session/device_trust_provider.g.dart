// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_trust_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeviceTrust)
final deviceTrustProvider = DeviceTrustProvider._();

final class DeviceTrustProvider
    extends $AsyncNotifierProvider<DeviceTrust, DeviceTrustStatus> {
  DeviceTrustProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTrustProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTrustHash();

  @$internal
  @override
  DeviceTrust create() => DeviceTrust();
}

String _$deviceTrustHash() => r'5d1705b2435d90266b7669b5537d5e27816b0634';

abstract class _$DeviceTrust extends $AsyncNotifier<DeviceTrustStatus> {
  FutureOr<DeviceTrustStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DeviceTrustStatus>, DeviceTrustStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DeviceTrustStatus>, DeviceTrustStatus>,
              AsyncValue<DeviceTrustStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
