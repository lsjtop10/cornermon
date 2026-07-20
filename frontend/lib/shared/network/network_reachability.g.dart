// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_reachability.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// connectivity_plus의 원시 이벤트(예: none→wifi, wifi→mobile)를 그대로 넘기지 않고,
/// "연결 가능한 상태로 바뀜"만 걸러서 내보낸다 — SSE 재연결 루프는 구체적인 인터페이스
/// 종류(wifi/mobile)에는 관심 없고 "지금 재시도해볼 만하다"는 신호만 필요하기 때문이다.

@ProviderFor(networkReachability)
final networkReachabilityProvider = NetworkReachabilityProvider._();

/// connectivity_plus의 원시 이벤트(예: none→wifi, wifi→mobile)를 그대로 넘기지 않고,
/// "연결 가능한 상태로 바뀜"만 걸러서 내보낸다 — SSE 재연결 루프는 구체적인 인터페이스
/// 종류(wifi/mobile)에는 관심 없고 "지금 재시도해볼 만하다"는 신호만 필요하기 때문이다.

final class NetworkReachabilityProvider
    extends
        $FunctionalProvider<
          NetworkReachability,
          NetworkReachability,
          NetworkReachability
        >
    with $Provider<NetworkReachability> {
  /// connectivity_plus의 원시 이벤트(예: none→wifi, wifi→mobile)를 그대로 넘기지 않고,
  /// "연결 가능한 상태로 바뀜"만 걸러서 내보낸다 — SSE 재연결 루프는 구체적인 인터페이스
  /// 종류(wifi/mobile)에는 관심 없고 "지금 재시도해볼 만하다"는 신호만 필요하기 때문이다.
  NetworkReachabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkReachabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkReachabilityHash();

  @$internal
  @override
  $ProviderElement<NetworkReachability> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NetworkReachability create(Ref ref) {
    return networkReachability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkReachability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkReachability>(value),
    );
  }
}

String _$networkReachabilityHash() =>
    r'fdfdaeca6a810d0d82c32b3296cb37f21252cdcb';
