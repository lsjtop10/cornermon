// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_track_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cornerList)
final cornerListProvider = CornerListFamily._();

final class CornerListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Corner>>,
          List<Corner>,
          FutureOr<List<Corner>>
        >
    with $FutureModifier<List<Corner>>, $FutureProvider<List<Corner>> {
  CornerListProvider._({
    required CornerListFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'cornerListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cornerListHash();

  @override
  String toString() {
    return r'cornerListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Corner>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Corner>> create(Ref ref) {
    final argument = this.argument as CampId;
    return cornerList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CornerListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cornerListHash() => r'be6637a5c5162996d623ed8b500a7c3d91b1f1b3';

final class CornerListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Corner>>, CampId> {
  CornerListFamily._()
    : super(
        retry: null,
        name: r'cornerListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CornerListProvider call(CampId campId) =>
      CornerListProvider._(argument: campId, from: this);

  @override
  String toString() => r'cornerListProvider';
}

@ProviderFor(cornerDetail)
final cornerDetailProvider = CornerDetailFamily._();

final class CornerDetailProvider
    extends $FunctionalProvider<AsyncValue<Corner>, Corner, FutureOr<Corner>>
    with $FutureModifier<Corner>, $FutureProvider<Corner> {
  CornerDetailProvider._({
    required CornerDetailFamily super.from,
    required CornerId super.argument,
  }) : super(
         retry: null,
         name: r'cornerDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cornerDetailHash();

  @override
  String toString() {
    return r'cornerDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Corner> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Corner> create(Ref ref) {
    final argument = this.argument as CornerId;
    return cornerDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CornerDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cornerDetailHash() => r'7af2ac06aaf352d48c13e63af23cd8b0d97e30ee';

final class CornerDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Corner>, CornerId> {
  CornerDetailFamily._()
    : super(
        retry: null,
        name: r'cornerDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CornerDetailProvider call(CornerId id) =>
      CornerDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'cornerDetailProvider';
}

/// TrackAuth로 자기 트랙이 속한 코너를 조회한다(GET /tracks/{trackId}/corner) — `cornerDetailProvider`와
/// 달리 AdminAuth가 아니라 진행자 세션 토큰으로 호출되므로 크로스 트랙 관리자 정보(activeTracks 등)는 오지 않는다.
/// 트랙 세션은 무만료라 로그인 스냅샷(`session.corner`)이 오래됐을 수 있으므로 화면 진입 시 한 번
/// 조회하고, `corners_updated` SSE(track_event_coordinator.dart) 수신 시 다시 무효화해 최신
/// targetMinutes를 반영한다.

@ProviderFor(trackCorner)
final trackCornerProvider = TrackCornerFamily._();

/// TrackAuth로 자기 트랙이 속한 코너를 조회한다(GET /tracks/{trackId}/corner) — `cornerDetailProvider`와
/// 달리 AdminAuth가 아니라 진행자 세션 토큰으로 호출되므로 크로스 트랙 관리자 정보(activeTracks 등)는 오지 않는다.
/// 트랙 세션은 무만료라 로그인 스냅샷(`session.corner`)이 오래됐을 수 있으므로 화면 진입 시 한 번
/// 조회하고, `corners_updated` SSE(track_event_coordinator.dart) 수신 시 다시 무효화해 최신
/// targetMinutes를 반영한다.

final class TrackCornerProvider
    extends $FunctionalProvider<AsyncValue<Corner>, Corner, FutureOr<Corner>>
    with $FutureModifier<Corner>, $FutureProvider<Corner> {
  /// TrackAuth로 자기 트랙이 속한 코너를 조회한다(GET /tracks/{trackId}/corner) — `cornerDetailProvider`와
  /// 달리 AdminAuth가 아니라 진행자 세션 토큰으로 호출되므로 크로스 트랙 관리자 정보(activeTracks 등)는 오지 않는다.
  /// 트랙 세션은 무만료라 로그인 스냅샷(`session.corner`)이 오래됐을 수 있으므로 화면 진입 시 한 번
  /// 조회하고, `corners_updated` SSE(track_event_coordinator.dart) 수신 시 다시 무효화해 최신
  /// targetMinutes를 반영한다.
  TrackCornerProvider._({
    required TrackCornerFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'trackCornerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackCornerHash();

  @override
  String toString() {
    return r'trackCornerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Corner> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Corner> create(Ref ref) {
    final argument = this.argument as TrackId;
    return trackCorner(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackCornerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackCornerHash() => r'8e90729a405c91d96f7dbecfa9950fa68b996095';

/// TrackAuth로 자기 트랙이 속한 코너를 조회한다(GET /tracks/{trackId}/corner) — `cornerDetailProvider`와
/// 달리 AdminAuth가 아니라 진행자 세션 토큰으로 호출되므로 크로스 트랙 관리자 정보(activeTracks 등)는 오지 않는다.
/// 트랙 세션은 무만료라 로그인 스냅샷(`session.corner`)이 오래됐을 수 있으므로 화면 진입 시 한 번
/// 조회하고, `corners_updated` SSE(track_event_coordinator.dart) 수신 시 다시 무효화해 최신
/// targetMinutes를 반영한다.

final class TrackCornerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Corner>, TrackId> {
  TrackCornerFamily._()
    : super(
        retry: null,
        name: r'trackCornerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// TrackAuth로 자기 트랙이 속한 코너를 조회한다(GET /tracks/{trackId}/corner) — `cornerDetailProvider`와
  /// 달리 AdminAuth가 아니라 진행자 세션 토큰으로 호출되므로 크로스 트랙 관리자 정보(activeTracks 등)는 오지 않는다.
  /// 트랙 세션은 무만료라 로그인 스냅샷(`session.corner`)이 오래됐을 수 있으므로 화면 진입 시 한 번
  /// 조회하고, `corners_updated` SSE(track_event_coordinator.dart) 수신 시 다시 무효화해 최신
  /// targetMinutes를 반영한다.

  TrackCornerProvider call(TrackId trackId) =>
      TrackCornerProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackCornerProvider';
}

@ProviderFor(createCorner)
final createCornerProvider = CreateCornerFamily._();

final class CreateCornerProvider
    extends $FunctionalProvider<AsyncValue<Corner>, Corner, FutureOr<Corner>>
    with $FutureModifier<Corner>, $FutureProvider<Corner> {
  CreateCornerProvider._({
    required CreateCornerFamily super.from,
    required (CampId, String, int) super.argument,
  }) : super(
         retry: noRetry,
         name: r'createCornerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createCornerHash();

  @override
  String toString() {
    return r'createCornerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Corner> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Corner> create(Ref ref) {
    final argument = this.argument as (CampId, String, int);
    return createCorner(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateCornerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createCornerHash() => r'8991ab69aaee5892e39846ff4b23021d87f8924f';

final class CreateCornerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Corner>, (CampId, String, int)> {
  CreateCornerFamily._()
    : super(
        retry: noRetry,
        name: r'createCornerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreateCornerProvider call(CampId campId, String name, int targetMinutes) =>
      CreateCornerProvider._(
        argument: (campId, name, targetMinutes),
        from: this,
      );

  @override
  String toString() => r'createCornerProvider';
}

@ProviderFor(bulkUpdateCorners)
final bulkUpdateCornersProvider = BulkUpdateCornersFamily._();

final class BulkUpdateCornersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Corner>>,
          List<Corner>,
          FutureOr<List<Corner>>
        >
    with $FutureModifier<List<Corner>>, $FutureProvider<List<Corner>> {
  BulkUpdateCornersProvider._({
    required BulkUpdateCornersFamily super.from,
    required List<CornerUpdateInput> super.argument,
  }) : super(
         retry: null,
         name: r'bulkUpdateCornersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bulkUpdateCornersHash();

  @override
  String toString() {
    return r'bulkUpdateCornersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Corner>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Corner>> create(Ref ref) {
    final argument = this.argument as List<CornerUpdateInput>;
    return bulkUpdateCorners(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BulkUpdateCornersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bulkUpdateCornersHash() => r'c75d37b88cbb508bfa65ccd26382f571c3e34cde';

final class BulkUpdateCornersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Corner>>,
          List<CornerUpdateInput>
        > {
  BulkUpdateCornersFamily._()
    : super(
        retry: null,
        name: r'bulkUpdateCornersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BulkUpdateCornersProvider call(List<CornerUpdateInput> updates) =>
      BulkUpdateCornersProvider._(argument: updates, from: this);

  @override
  String toString() => r'bulkUpdateCornersProvider';
}

@ProviderFor(deleteCorner)
final deleteCornerProvider = DeleteCornerFamily._();

final class DeleteCornerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteCornerProvider._({
    required DeleteCornerFamily super.from,
    required CornerId super.argument,
  }) : super(
         retry: null,
         name: r'deleteCornerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteCornerHash();

  @override
  String toString() {
    return r'deleteCornerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as CornerId;
    return deleteCorner(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteCornerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteCornerHash() => r'301b07435cb00e8b31794ba91f1b447198925920';

final class DeleteCornerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, CornerId> {
  DeleteCornerFamily._()
    : super(
        retry: null,
        name: r'deleteCornerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteCornerProvider call(CornerId id) =>
      DeleteCornerProvider._(argument: id, from: this);

  @override
  String toString() => r'deleteCornerProvider';
}

@ProviderFor(trackList)
final trackListProvider = TrackListFamily._();

final class TrackListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Track>>,
          List<Track>,
          FutureOr<List<Track>>
        >
    with $FutureModifier<List<Track>>, $FutureProvider<List<Track>> {
  TrackListProvider._({
    required TrackListFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'trackListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackListHash();

  @override
  String toString() {
    return r'trackListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Track>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Track>> create(Ref ref) {
    final argument = this.argument as CampId;
    return trackList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackListHash() => r'7565d3d161a0adde9a94d865bd0df208ac786030';

final class TrackListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Track>>, CampId> {
  TrackListFamily._()
    : super(
        retry: null,
        name: r'trackListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrackListProvider call(CampId campId) =>
      TrackListProvider._(argument: campId, from: this);

  @override
  String toString() => r'trackListProvider';
}

@ProviderFor(cornerTrackList)
final cornerTrackListProvider = CornerTrackListFamily._();

final class CornerTrackListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Track>>,
          List<Track>,
          FutureOr<List<Track>>
        >
    with $FutureModifier<List<Track>>, $FutureProvider<List<Track>> {
  CornerTrackListProvider._({
    required CornerTrackListFamily super.from,
    required CornerId super.argument,
  }) : super(
         retry: null,
         name: r'cornerTrackListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cornerTrackListHash();

  @override
  String toString() {
    return r'cornerTrackListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Track>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Track>> create(Ref ref) {
    final argument = this.argument as CornerId;
    return cornerTrackList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CornerTrackListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cornerTrackListHash() => r'03bf2b8060c5fb42ebd03e2ef800654d811df5b3';

final class CornerTrackListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Track>>, CornerId> {
  CornerTrackListFamily._()
    : super(
        retry: null,
        name: r'cornerTrackListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CornerTrackListProvider call(CornerId cornerId) =>
      CornerTrackListProvider._(argument: cornerId, from: this);

  @override
  String toString() => r'cornerTrackListProvider';
}

@ProviderFor(createTracksForCorner)
final createTracksForCornerProvider = CreateTracksForCornerFamily._();

final class CreateTracksForCornerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TrackPin>>,
          List<TrackPin>,
          FutureOr<List<TrackPin>>
        >
    with $FutureModifier<List<TrackPin>>, $FutureProvider<List<TrackPin>> {
  CreateTracksForCornerProvider._({
    required CreateTracksForCornerFamily super.from,
    required (CampId, CornerId, int) super.argument,
  }) : super(
         retry: noRetry,
         name: r'createTracksForCornerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createTracksForCornerHash();

  @override
  String toString() {
    return r'createTracksForCornerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<TrackPin>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrackPin>> create(Ref ref) {
    final argument = this.argument as (CampId, CornerId, int);
    return createTracksForCorner(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateTracksForCornerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createTracksForCornerHash() =>
    r'a87511105b8ac01a4d6f766e5d67136174992a04';

final class CreateTracksForCornerFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<TrackPin>>,
          (CampId, CornerId, int)
        > {
  CreateTracksForCornerFamily._()
    : super(
        retry: noRetry,
        name: r'createTracksForCornerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreateTracksForCornerProvider call(
    CampId campId,
    CornerId cornerId,
    int count,
  ) => CreateTracksForCornerProvider._(
    argument: (campId, cornerId, count),
    from: this,
  );

  @override
  String toString() => r'createTracksForCornerProvider';
}

@ProviderFor(bulkDeleteTracks)
final bulkDeleteTracksProvider = BulkDeleteTracksFamily._();

final class BulkDeleteTracksProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  BulkDeleteTracksProvider._({
    required BulkDeleteTracksFamily super.from,
    required List<TrackId> super.argument,
  }) : super(
         retry: null,
         name: r'bulkDeleteTracksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bulkDeleteTracksHash();

  @override
  String toString() {
    return r'bulkDeleteTracksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as List<TrackId>;
    return bulkDeleteTracks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BulkDeleteTracksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bulkDeleteTracksHash() => r'b5c12bd29993e673d53f0f9fe552a9ea999a0ecd';

final class BulkDeleteTracksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, List<TrackId>> {
  BulkDeleteTracksFamily._()
    : super(
        retry: null,
        name: r'bulkDeleteTracksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BulkDeleteTracksProvider call(List<TrackId> trackIds) =>
      BulkDeleteTracksProvider._(argument: trackIds, from: this);

  @override
  String toString() => r'bulkDeleteTracksProvider';
}

@ProviderFor(replaceTrack)
final replaceTrackProvider = ReplaceTrackFamily._();

final class ReplaceTrackProvider
    extends
        $FunctionalProvider<AsyncValue<TrackPin>, TrackPin, FutureOr<TrackPin>>
    with $FutureModifier<TrackPin>, $FutureProvider<TrackPin> {
  ReplaceTrackProvider._({
    required ReplaceTrackFamily super.from,
    required (TrackId, CornerId) super.argument,
  }) : super(
         retry: null,
         name: r'replaceTrackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$replaceTrackHash();

  @override
  String toString() {
    return r'replaceTrackProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<TrackPin> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TrackPin> create(Ref ref) {
    final argument = this.argument as (TrackId, CornerId);
    return replaceTrack(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ReplaceTrackProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$replaceTrackHash() => r'031600b2f257e4df96e1d10a753286817738a38b';

final class ReplaceTrackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TrackPin>, (TrackId, CornerId)> {
  ReplaceTrackFamily._()
    : super(
        retry: null,
        name: r'replaceTrackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReplaceTrackProvider call(TrackId id, CornerId newCornerId) =>
      ReplaceTrackProvider._(argument: (id, newCornerId), from: this);

  @override
  String toString() => r'replaceTrackProvider';
}

@ProviderFor(regeneratePin)
final regeneratePinProvider = RegeneratePinFamily._();

final class RegeneratePinProvider
    extends
        $FunctionalProvider<AsyncValue<TrackPin>, TrackPin, FutureOr<TrackPin>>
    with $FutureModifier<TrackPin>, $FutureProvider<TrackPin> {
  RegeneratePinProvider._({
    required RegeneratePinFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'regeneratePinProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$regeneratePinHash();

  @override
  String toString() {
    return r'regeneratePinProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TrackPin> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TrackPin> create(Ref ref) {
    final argument = this.argument as TrackId;
    return regeneratePin(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RegeneratePinProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$regeneratePinHash() => r'2fcaa7ba6ce38d7a363a0ccadf0929279c1c9edf';

final class RegeneratePinFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TrackPin>, TrackId> {
  RegeneratePinFamily._()
    : super(
        retry: null,
        name: r'regeneratePinProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RegeneratePinProvider call(TrackId id) =>
      RegeneratePinProvider._(argument: id, from: this);

  @override
  String toString() => r'regeneratePinProvider';
}

@ProviderFor(exportAllTracksCsv)
final exportAllTracksCsvProvider = ExportAllTracksCsvFamily._();

final class ExportAllTracksCsvProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExportTracksResponse>,
          ExportTracksResponse,
          FutureOr<ExportTracksResponse>
        >
    with
        $FutureModifier<ExportTracksResponse>,
        $FutureProvider<ExportTracksResponse> {
  ExportAllTracksCsvProvider._({
    required ExportAllTracksCsvFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'exportAllTracksCsvProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportAllTracksCsvHash();

  @override
  String toString() {
    return r'exportAllTracksCsvProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ExportTracksResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExportTracksResponse> create(Ref ref) {
    final argument = this.argument as CampId;
    return exportAllTracksCsv(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExportAllTracksCsvProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportAllTracksCsvHash() =>
    r'1de6abefff089d6e7979f8f72befe3823cd07e2e';

final class ExportAllTracksCsvFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ExportTracksResponse>, CampId> {
  ExportAllTracksCsvFamily._()
    : super(
        retry: null,
        name: r'exportAllTracksCsvProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExportAllTracksCsvProvider call(CampId campId) =>
      ExportAllTracksCsvProvider._(argument: campId, from: this);

  @override
  String toString() => r'exportAllTracksCsvProvider';
}

@ProviderFor(exportTrackPdf)
final exportTrackPdfProvider = ExportTrackPdfFamily._();

final class ExportTrackPdfProvider
    extends
        $FunctionalProvider<AsyncValue<TrackPin>, TrackPin, FutureOr<TrackPin>>
    with $FutureModifier<TrackPin>, $FutureProvider<TrackPin> {
  ExportTrackPdfProvider._({
    required ExportTrackPdfFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'exportTrackPdfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportTrackPdfHash();

  @override
  String toString() {
    return r'exportTrackPdfProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TrackPin> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TrackPin> create(Ref ref) {
    final argument = this.argument as TrackId;
    return exportTrackPdf(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExportTrackPdfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportTrackPdfHash() => r'73e5940dcf63433667dcf0b482c3f5eab26f655f';

final class ExportTrackPdfFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TrackPin>, TrackId> {
  ExportTrackPdfFamily._()
    : super(
        retry: null,
        name: r'exportTrackPdfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExportTrackPdfProvider call(TrackId id) =>
      ExportTrackPdfProvider._(argument: id, from: this);

  @override
  String toString() => r'exportTrackPdfProvider';
}
