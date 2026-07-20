// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_event_stream.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrackConnection)
final trackConnectionProvider = TrackConnectionFamily._();

final class TrackConnectionProvider
    extends $NotifierProvider<TrackConnection, TrackConnectionState> {
  TrackConnectionProvider._({
    required TrackConnectionFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'trackConnectionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackConnectionHash();

  @override
  String toString() {
    return r'trackConnectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TrackConnection create() => TrackConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackConnectionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TrackConnectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackConnectionHash() => r'3da84620855636876bac0561b355314d776a6f18';

final class TrackConnectionFamily extends $Family
    with
        $ClassFamilyOverride<
          TrackConnection,
          TrackConnectionState,
          TrackConnectionState,
          TrackConnectionState,
          TrackId
        > {
  TrackConnectionFamily._()
    : super(
        retry: null,
        name: r'trackConnectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TrackConnectionProvider call(TrackId trackId) =>
      TrackConnectionProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackConnectionProvider';
}

abstract class _$TrackConnection extends $Notifier<TrackConnectionState> {
  late final _$args = ref.$arg as TrackId;
  TrackId get trackId => _$args;

  TrackConnectionState build(TrackId trackId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TrackConnectionState, TrackConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrackConnectionState, TrackConnectionState>,
              TrackConnectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 원시 이벤트 스트림 — 에러/종료 시 지수 백오프(+지터) 후 재연결을 반복해 구독자에게는
/// 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임). 연결 상태(배너 표시)는
/// 도메인 알림 도착 여부가 아니라 SseClient의 연결/해제 콜백으로 직접 판단한다(TrackConnection).

@ProviderFor(trackEvents)
final trackEventsProvider = TrackEventsFamily._();

/// 원시 이벤트 스트림 — 에러/종료 시 지수 백오프(+지터) 후 재연결을 반복해 구독자에게는
/// 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임). 연결 상태(배너 표시)는
/// 도메인 알림 도착 여부가 아니라 SseClient의 연결/해제 콜백으로 직접 판단한다(TrackConnection).

final class TrackEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SSENotification>,
          SSENotification,
          Stream<SSENotification>
        >
    with $FutureModifier<SSENotification>, $StreamProvider<SSENotification> {
  /// 원시 이벤트 스트림 — 에러/종료 시 지수 백오프(+지터) 후 재연결을 반복해 구독자에게는
  /// 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임). 연결 상태(배너 표시)는
  /// 도메인 알림 도착 여부가 아니라 SseClient의 연결/해제 콜백으로 직접 판단한다(TrackConnection).
  TrackEventsProvider._({
    required TrackEventsFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'trackEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackEventsHash();

  @override
  String toString() {
    return r'trackEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SSENotification> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SSENotification> create(Ref ref) {
    final argument = this.argument as TrackId;
    return trackEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackEventsHash() => r'20f4c2d565465610cdc0f0cf7a619d332901370d';

/// 원시 이벤트 스트림 — 에러/종료 시 지수 백오프(+지터) 후 재연결을 반복해 구독자에게는
/// 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임). 연결 상태(배너 표시)는
/// 도메인 알림 도착 여부가 아니라 SseClient의 연결/해제 콜백으로 직접 판단한다(TrackConnection).

final class TrackEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SSENotification>, TrackId> {
  TrackEventsFamily._()
    : super(
        retry: null,
        name: r'trackEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 원시 이벤트 스트림 — 에러/종료 시 지수 백오프(+지터) 후 재연결을 반복해 구독자에게는
  /// 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임). 연결 상태(배너 표시)는
  /// 도메인 알림 도착 여부가 아니라 SseClient의 연결/해제 콜백으로 직접 판단한다(TrackConnection).

  TrackEventsProvider call(TrackId trackId) =>
      TrackEventsProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackEventsProvider';
}
