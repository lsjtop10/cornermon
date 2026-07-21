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

String _$deviceTrustHash() => r'c46ad0d7768b91b0ba5a9b42409cf964791e4803';

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

/// 신뢰기기 등록 시 발급받아 저장해둔 토큰 — B1 PIN 로그인(`X-Device-Token` 헤더)에만 쓰인다.

@ProviderFor(deviceTrustToken)
final deviceTrustTokenProvider = DeviceTrustTokenProvider._();

/// 신뢰기기 등록 시 발급받아 저장해둔 토큰 — B1 PIN 로그인(`X-Device-Token` 헤더)에만 쓰인다.

final class DeviceTrustTokenProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 신뢰기기 등록 시 발급받아 저장해둔 토큰 — B1 PIN 로그인(`X-Device-Token` 헤더)에만 쓰인다.
  DeviceTrustTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTrustTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTrustTokenHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return deviceTrustToken(ref);
  }
}

String _$deviceTrustTokenHash() => r'601854c4b6e6d825daf8a4f1b635b7302afec13f';
