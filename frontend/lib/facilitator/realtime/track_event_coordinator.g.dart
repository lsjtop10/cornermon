// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_event_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 인증된 트랙 세션의 SSE 수신·재조회 경계를 한 곳에서 관리한다.
///
/// 메시지·공지, 방문 상태, 세션 종료는 서로 다른 도메인 관심사지만, 현재는 모두 같은 트랙
/// 세션의 단일 SSE 연결에서 도착하고 각 provider를 재조회시키는 얇은 어댑터다. 따라서 지금은
/// 연결·재연결·세션 수명을 한 코디네이터에 둔다. 각 이벤트에 독자적인 정책 또는 화면별 구독
/// 수명이 생길 때에만 메시지/방문/세션 코디네이터로 분리한다.
///
/// 이벤트 분기는 위젯이 아니라 이 Notifier에 둔다. 위젯 build() 안에서 스트림 값에 반응해
/// 동기적으로 ref.invalidate를 호출하면 빌드 사이클 도중 provider를 바꾸다 예외가 날 수 있다.
/// 화면은 이 결과만 watch하고, 앱 루트가 인증 세션 동안의 생명주기를 소유한다.

@ProviderFor(TrackEventCoordinator)
final trackEventCoordinatorProvider = TrackEventCoordinatorFamily._();

/// SSE 이벤트 분기는 위젯이 아니라 이 전용 Notifier에 둔다 — 위젯 build() 안에서 스트림
/// 값에 반응해 동기적으로 ref.invalidate를 호출하면 빌드 사이클 도중 provider를 바꾸다 예외가
/// 날 수 있다. ref.listen은 provider의 build() 안에서 쓰는 게 표준 패턴이고(콜백이 프레임
/// 이후 비동기로 실행되어 "빌드 도중 변경" 제약이 없음), 화면(위젯)은 이 결과를 watch만 해서
/// 생명주기(자동 dispose)만 공유한다(§04 plan).
final class TrackEventCoordinatorProvider
    extends $NotifierProvider<TrackEventCoordinator, void> {
  /// SSE 이벤트 분기는 위젯이 아니라 이 전용 Notifier에 둔다 — 위젯 build() 안에서 스트림
  /// 값에 반응해 동기적으로 ref.invalidate를 호출하면 빌드 사이클 도중 provider를 바꾸다 예외가
  /// 날 수 있다. ref.listen은 provider의 build() 안에서 쓰는 게 표준 패턴이고(콜백이 프레임
  /// 이후 비동기로 실행되어 "빌드 도중 변경" 제약이 없음), 화면(위젯)은 이 결과를 watch만 해서
  /// 생명주기(자동 dispose)만 공유한다(§04 plan).
  TrackEventCoordinatorProvider._({
    required TrackEventCoordinatorFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'trackEventCoordinatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackEventCoordinatorHash();

  @override
  String toString() {
    return r'trackEventCoordinatorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TrackEventCoordinator create() => TrackEventCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrackEventCoordinatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackEventCoordinatorHash() =>
    r'8ce32258b2d8547ca0d84d484a23d7a5f23959ad';

/// SSE 이벤트 분기는 위젯이 아니라 이 전용 Notifier에 둔다 — 위젯 build() 안에서 스트림
/// 값에 반응해 동기적으로 ref.invalidate를 호출하면 빌드 사이클 도중 provider를 바꾸다 예외가
/// 날 수 있다. ref.listen은 provider의 build() 안에서 쓰는 게 표준 패턴이고(콜백이 프레임
/// 이후 비동기로 실행되어 "빌드 도중 변경" 제약이 없음), 화면(위젯)은 이 결과를 watch만 해서
/// 생명주기(자동 dispose)만 공유한다(§04 plan).

final class TrackEventCoordinatorFamily extends $Family
    with
        $ClassFamilyOverride<TrackEventCoordinator, void, void, void, TrackId> {
  TrackEventCoordinatorFamily._()
    : super(
        retry: null,
        name: r'trackEventCoordinatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// SSE 이벤트 분기는 위젯이 아니라 이 전용 Notifier에 둔다 — 위젯 build() 안에서 스트림
  /// 값에 반응해 동기적으로 ref.invalidate를 호출하면 빌드 사이클 도중 provider를 바꾸다 예외가
  /// 날 수 있다. ref.listen은 provider의 build() 안에서 쓰는 게 표준 패턴이고(콜백이 프레임
  /// 이후 비동기로 실행되어 "빌드 도중 변경" 제약이 없음), 화면(위젯)은 이 결과를 watch만 해서
  /// 생명주기(자동 dispose)만 공유한다(§04 plan).

  TrackEventCoordinatorProvider call(TrackId trackId) =>
      TrackEventCoordinatorProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackEventCoordinatorProvider';
}

/// SSE 이벤트 분기는 위젯이 아니라 이 전용 Notifier에 둔다 — 위젯 build() 안에서 스트림
/// 값에 반응해 동기적으로 ref.invalidate를 호출하면 빌드 사이클 도중 provider를 바꾸다 예외가
/// 날 수 있다. ref.listen은 provider의 build() 안에서 쓰는 게 표준 패턴이고(콜백이 프레임
/// 이후 비동기로 실행되어 "빌드 도중 변경" 제약이 없음), 화면(위젯)은 이 결과를 watch만 해서
/// 생명주기(자동 dispose)만 공유한다(§04 plan).

abstract class _$TrackEventCoordinator extends $Notifier<void> {
  late final _$args = ref.$arg as TrackId;
  TrackId get trackId => _$args;

  void build(TrackId trackId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
