// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_direct_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedDirectTrackId)
final selectedDirectTrackIdProvider = SelectedDirectTrackIdProvider._();

final class SelectedDirectTrackIdProvider
    extends $NotifierProvider<SelectedDirectTrackId, TrackId?> {
  SelectedDirectTrackIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDirectTrackIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDirectTrackIdHash();

  @$internal
  @override
  SelectedDirectTrackId create() => SelectedDirectTrackId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackId? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackId?>(value),
    );
  }
}

String _$selectedDirectTrackIdHash() =>
    r'd77aa5d49c6e8cd8e9349105a49cc35dbc848bd6';

abstract class _$SelectedDirectTrackId extends $Notifier<TrackId?> {
  TrackId? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TrackId?, TrackId?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrackId?, TrackId?>,
              TrackId?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 캠프의 전체 트랙(ACTIVE + DELETED) × 트랙별 메시지 목록을 조합해
/// 좌측 목록에 필요한 미리보기·안읽음 카운트를 만든다.
/// **주의(N+1 호출)**: 트랙별 GET을 트랙 수만큼 병렬 호출한다 — 캠프당 트랙 10~20개
/// 가정에서는 허용, 트랙이 훨씬 많아지면 서버에 요약 엔드포인트를 신설해야 한다(범위 밖).

@ProviderFor(trackDirectSummaries)
final trackDirectSummariesProvider = TrackDirectSummariesFamily._();

/// 캠프의 전체 트랙(ACTIVE + DELETED) × 트랙별 메시지 목록을 조합해
/// 좌측 목록에 필요한 미리보기·안읽음 카운트를 만든다.
/// **주의(N+1 호출)**: 트랙별 GET을 트랙 수만큼 병렬 호출한다 — 캠프당 트랙 10~20개
/// 가정에서는 허용, 트랙이 훨씬 많아지면 서버에 요약 엔드포인트를 신설해야 한다(범위 밖).

final class TrackDirectSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrackDirectSummary>>,
          List<TrackDirectSummary>,
          FutureOr<List<TrackDirectSummary>>
        >
    with
        $FutureModifier<List<TrackDirectSummary>>,
        $FutureProvider<List<TrackDirectSummary>> {
  /// 캠프의 전체 트랙(ACTIVE + DELETED) × 트랙별 메시지 목록을 조합해
  /// 좌측 목록에 필요한 미리보기·안읽음 카운트를 만든다.
  /// **주의(N+1 호출)**: 트랙별 GET을 트랙 수만큼 병렬 호출한다 — 캠프당 트랙 10~20개
  /// 가정에서는 허용, 트랙이 훨씬 많아지면 서버에 요약 엔드포인트를 신설해야 한다(범위 밖).
  TrackDirectSummariesProvider._({
    required TrackDirectSummariesFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'trackDirectSummariesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackDirectSummariesHash();

  @override
  String toString() {
    return r'trackDirectSummariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TrackDirectSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrackDirectSummary>> create(Ref ref) {
    final argument = this.argument as CampId;
    return trackDirectSummaries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackDirectSummariesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackDirectSummariesHash() =>
    r'52fae8fbc0471fe46e08dafcb43323c151772ce3';

/// 캠프의 전체 트랙(ACTIVE + DELETED) × 트랙별 메시지 목록을 조합해
/// 좌측 목록에 필요한 미리보기·안읽음 카운트를 만든다.
/// **주의(N+1 호출)**: 트랙별 GET을 트랙 수만큼 병렬 호출한다 — 캠프당 트랙 10~20개
/// 가정에서는 허용, 트랙이 훨씬 많아지면 서버에 요약 엔드포인트를 신설해야 한다(범위 밖).

final class TrackDirectSummariesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TrackDirectSummary>>, CampId> {
  TrackDirectSummariesFamily._()
    : super(
        retry: null,
        name: r'trackDirectSummariesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 캠프의 전체 트랙(ACTIVE + DELETED) × 트랙별 메시지 목록을 조합해
  /// 좌측 목록에 필요한 미리보기·안읽음 카운트를 만든다.
  /// **주의(N+1 호출)**: 트랙별 GET을 트랙 수만큼 병렬 호출한다 — 캠프당 트랙 10~20개
  /// 가정에서는 허용, 트랙이 훨씬 많아지면 서버에 요약 엔드포인트를 신설해야 한다(범위 밖).

  TrackDirectSummariesProvider call(CampId campId) =>
      TrackDirectSummariesProvider._(argument: campId, from: this);

  @override
  String toString() => r'trackDirectSummariesProvider';
}
