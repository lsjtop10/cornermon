// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_event_stream.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 원시 이벤트 스트림 — 에러/종료 시 짧은 backoff 후 재연결을 반복해
/// 구독자에게는 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임).

@ProviderFor(trackEvents)
final trackEventsProvider = TrackEventsFamily._();

/// 원시 이벤트 스트림 — 에러/종료 시 짧은 backoff 후 재연결을 반복해
/// 구독자에게는 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임).

final class TrackEventsProvider
    extends
        $FunctionalProvider<AsyncValue<SseEvent>, SseEvent, Stream<SseEvent>>
    with $FutureModifier<SseEvent>, $StreamProvider<SseEvent> {
  /// 원시 이벤트 스트림 — 에러/종료 시 짧은 backoff 후 재연결을 반복해
  /// 구독자에게는 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임).
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
  $StreamProviderElement<SseEvent> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SseEvent> create(Ref ref) {
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

String _$trackEventsHash() => r'61d4fe7031be40e1ffb7467d95666eda6f71874b';

/// 원시 이벤트 스트림 — 에러/종료 시 짧은 backoff 후 재연결을 반복해
/// 구독자에게는 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임).

final class TrackEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SseEvent>, TrackId> {
  TrackEventsFamily._()
    : super(
        retry: null,
        name: r'trackEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 원시 이벤트 스트림 — 에러/종료 시 짧은 backoff 후 재연결을 반복해
  /// 구독자에게는 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임).

  TrackEventsProvider call(TrackId trackId) =>
      TrackEventsProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackEventsProvider';
}

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
         isAutoDispose: true,
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

String _$trackConnectionHash() => r'9ddb9294beca557cb5d5a6dd5414b597d6daa1f4';

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
        isAutoDispose: true,
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
