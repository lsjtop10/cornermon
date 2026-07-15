// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentVisit)
final currentVisitProvider = CurrentVisitFamily._();

final class CurrentVisitProvider
    extends
        $FunctionalProvider<
          AsyncValue<VisitSummary?>,
          VisitSummary?,
          FutureOr<VisitSummary?>
        >
    with $FutureModifier<VisitSummary?>, $FutureProvider<VisitSummary?> {
  CurrentVisitProvider._({
    required CurrentVisitFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'currentVisitProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentVisitHash();

  @override
  String toString() {
    return r'currentVisitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VisitSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VisitSummary?> create(Ref ref) {
    final argument = this.argument as TrackId;
    return currentVisit(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentVisitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentVisitHash() => r'fcd3a075f9e41fc859ee62b7c0b95e712e2b83ec';

final class CurrentVisitFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VisitSummary?>, TrackId> {
  CurrentVisitFamily._()
    : super(
        retry: null,
        name: r'currentVisitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentVisitProvider call(TrackId trackId) =>
      CurrentVisitProvider._(argument: trackId, from: this);

  @override
  String toString() => r'currentVisitProvider';
}

@ProviderFor(VisitActions)
final visitActionsProvider = VisitActionsFamily._();

final class VisitActionsProvider extends $NotifierProvider<VisitActions, void> {
  VisitActionsProvider._({
    required VisitActionsFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'visitActionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visitActionsHash();

  @override
  String toString() {
    return r'visitActionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VisitActions create() => VisitActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VisitActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visitActionsHash() => r'5fa678fd04dc169bd257545b2f94c86e732698a2';

final class VisitActionsFamily extends $Family
    with $ClassFamilyOverride<VisitActions, void, void, void, TrackId> {
  VisitActionsFamily._()
    : super(
        retry: null,
        name: r'visitActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VisitActionsProvider call(TrackId trackId) =>
      VisitActionsProvider._(argument: trackId, from: this);

  @override
  String toString() => r'visitActionsProvider';
}

abstract class _$VisitActions extends $Notifier<void> {
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
