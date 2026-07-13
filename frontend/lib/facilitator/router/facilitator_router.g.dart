// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facilitator_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// GoRouter는 redirect 콜백 안에서 ref.read로 현재 상태를 동기적으로 읽는다(ref.watch 아님 —
/// redirect는 위젯 빌드가 아니므로 매 상태변화마다 재실행되지 않는다. 재실행 트리거는 refreshListenable이 담당).

@ProviderFor(facilitatorRouter)
final facilitatorRouterProvider = FacilitatorRouterProvider._();

/// GoRouter는 redirect 콜백 안에서 ref.read로 현재 상태를 동기적으로 읽는다(ref.watch 아님 —
/// redirect는 위젯 빌드가 아니므로 매 상태변화마다 재실행되지 않는다. 재실행 트리거는 refreshListenable이 담당).

final class FacilitatorRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// GoRouter는 redirect 콜백 안에서 ref.read로 현재 상태를 동기적으로 읽는다(ref.watch 아님 —
  /// redirect는 위젯 빌드가 아니므로 매 상태변화마다 재실행되지 않는다. 재실행 트리거는 refreshListenable이 담당).
  FacilitatorRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilitatorRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilitatorRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return facilitatorRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$facilitatorRouterHash() => r'1b44fc350414aea5f2bc9f6684074bd886468f4b';
