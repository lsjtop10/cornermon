// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_api_environment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 선택된 API 환경. `apiClientProvider`가 이 값을 watch해 base URL을 결정하므로,
/// `keepAlive: true`로 둬야 앱 전체에서 단일 소스로 유지된다 — `apiClientProvider`와 동일한
/// 이유(§2.1 DEVELOPER_GUIDE, "공유 인프라는 keepAlive로 고정").
///
/// 앱 재시작 후에는 항상 운영으로 되돌아간다(영속화하지 않음) — 심사/연습 세션은 한 번의
/// 앱 실행 안에서 끝나는 게 보통이고, 재시작마다 다시 운영을 기본값으로 보는 편이
/// 실캠프 사용자가 잘못 데모 환경에 머무는 사고를 구조적으로 막는다.

@ProviderFor(ActiveApiEnvironment)
final activeApiEnvironmentProvider = ActiveApiEnvironmentProvider._();

/// 현재 선택된 API 환경. `apiClientProvider`가 이 값을 watch해 base URL을 결정하므로,
/// `keepAlive: true`로 둬야 앱 전체에서 단일 소스로 유지된다 — `apiClientProvider`와 동일한
/// 이유(§2.1 DEVELOPER_GUIDE, "공유 인프라는 keepAlive로 고정").
///
/// 앱 재시작 후에는 항상 운영으로 되돌아간다(영속화하지 않음) — 심사/연습 세션은 한 번의
/// 앱 실행 안에서 끝나는 게 보통이고, 재시작마다 다시 운영을 기본값으로 보는 편이
/// 실캠프 사용자가 잘못 데모 환경에 머무는 사고를 구조적으로 막는다.
final class ActiveApiEnvironmentProvider
    extends $NotifierProvider<ActiveApiEnvironment, ApiEnvironment> {
  /// 현재 선택된 API 환경. `apiClientProvider`가 이 값을 watch해 base URL을 결정하므로,
  /// `keepAlive: true`로 둬야 앱 전체에서 단일 소스로 유지된다 — `apiClientProvider`와 동일한
  /// 이유(§2.1 DEVELOPER_GUIDE, "공유 인프라는 keepAlive로 고정").
  ///
  /// 앱 재시작 후에는 항상 운영으로 되돌아간다(영속화하지 않음) — 심사/연습 세션은 한 번의
  /// 앱 실행 안에서 끝나는 게 보통이고, 재시작마다 다시 운영을 기본값으로 보는 편이
  /// 실캠프 사용자가 잘못 데모 환경에 머무는 사고를 구조적으로 막는다.
  ActiveApiEnvironmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeApiEnvironmentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeApiEnvironmentHash();

  @$internal
  @override
  ActiveApiEnvironment create() => ActiveApiEnvironment();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiEnvironment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiEnvironment>(value),
    );
  }
}

String _$activeApiEnvironmentHash() =>
    r'd055fed9e7ae649ec7fcf4a8e119ddb562ba29a5';

/// 현재 선택된 API 환경. `apiClientProvider`가 이 값을 watch해 base URL을 결정하므로,
/// `keepAlive: true`로 둬야 앱 전체에서 단일 소스로 유지된다 — `apiClientProvider`와 동일한
/// 이유(§2.1 DEVELOPER_GUIDE, "공유 인프라는 keepAlive로 고정").
///
/// 앱 재시작 후에는 항상 운영으로 되돌아간다(영속화하지 않음) — 심사/연습 세션은 한 번의
/// 앱 실행 안에서 끝나는 게 보통이고, 재시작마다 다시 운영을 기본값으로 보는 편이
/// 실캠프 사용자가 잘못 데모 환경에 머무는 사고를 구조적으로 막는다.

abstract class _$ActiveApiEnvironment extends $Notifier<ApiEnvironment> {
  ApiEnvironment build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ApiEnvironment, ApiEnvironment>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ApiEnvironment, ApiEnvironment>,
              ApiEnvironment,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
