// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(visitScanFlowApi)
final visitScanFlowApiProvider = VisitScanFlowApiProvider._();

final class VisitScanFlowApiProvider
    extends
        $FunctionalProvider<
          CVisitScanFlowApi,
          CVisitScanFlowApi,
          CVisitScanFlowApi
        >
    with $Provider<CVisitScanFlowApi> {
  VisitScanFlowApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visitScanFlowApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visitScanFlowApiHash();

  @$internal
  @override
  $ProviderElement<CVisitScanFlowApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CVisitScanFlowApi create(Ref ref) {
    return visitScanFlowApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CVisitScanFlowApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CVisitScanFlowApi>(value),
    );
  }
}

String _$visitScanFlowApiHash() => r'0990e63ead4682a6f59bf44ef4b778163a3197eb';

@ProviderFor(groupList)
final groupListProvider = GroupListFamily._();

final class GroupListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Group>>,
          List<Group>,
          FutureOr<List<Group>>
        >
    with $FutureModifier<List<Group>>, $FutureProvider<List<Group>> {
  GroupListProvider._({
    required GroupListFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'groupListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupListHash();

  @override
  String toString() {
    return r'groupListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Group>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Group>> create(Ref ref) {
    final argument = this.argument as CampId;
    return groupList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupListHash() => r'920da8dab0a7ca2e27e2499508394b69f8e1d45c';

final class GroupListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Group>>, CampId> {
  GroupListFamily._()
    : super(
        retry: null,
        name: r'groupListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupListProvider call(CampId campId) =>
      GroupListProvider._(argument: campId, from: this);

  @override
  String toString() => r'groupListProvider';
}

@ProviderFor(groupDetail)
final groupDetailProvider = GroupDetailFamily._();

final class GroupDetailProvider
    extends $FunctionalProvider<AsyncValue<Group>, Group, FutureOr<Group>>
    with $FutureModifier<Group>, $FutureProvider<Group> {
  GroupDetailProvider._({
    required GroupDetailFamily super.from,
    required GroupId super.argument,
  }) : super(
         retry: null,
         name: r'groupDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupDetailHash();

  @override
  String toString() {
    return r'groupDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Group> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Group> create(Ref ref) {
    final argument = this.argument as GroupId;
    return groupDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupDetailHash() => r'65a0a036ed5c7c000ded076b552213ad51e4a142';

final class GroupDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Group>, GroupId> {
  GroupDetailFamily._()
    : super(
        retry: null,
        name: r'groupDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupDetailProvider call(GroupId id) =>
      GroupDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'groupDetailProvider';
}

@ProviderFor(groupVisits)
final groupVisitsProvider = GroupVisitsFamily._();

final class GroupVisitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitSummary>>,
          List<VisitSummary>,
          FutureOr<List<VisitSummary>>
        >
    with
        $FutureModifier<List<VisitSummary>>,
        $FutureProvider<List<VisitSummary>> {
  GroupVisitsProvider._({
    required GroupVisitsFamily super.from,
    required GroupId super.argument,
  }) : super(
         retry: null,
         name: r'groupVisitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupVisitsHash();

  @override
  String toString() {
    return r'groupVisitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VisitSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VisitSummary>> create(Ref ref) {
    final argument = this.argument as GroupId;
    return groupVisits(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupVisitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupVisitsHash() => r'7da94f761c8adb908f2deacc222fe3bd44cd9ca5';

final class GroupVisitsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VisitSummary>>, GroupId> {
  GroupVisitsFamily._()
    : super(
        retry: null,
        name: r'groupVisitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupVisitsProvider call(GroupId id) =>
      GroupVisitsProvider._(argument: id, from: this);

  @override
  String toString() => r'groupVisitsProvider';
}

@ProviderFor(trackScopedGroups)
final trackScopedGroupsProvider = TrackScopedGroupsFamily._();

final class TrackScopedGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Group>>,
          List<Group>,
          FutureOr<List<Group>>
        >
    with $FutureModifier<List<Group>>, $FutureProvider<List<Group>> {
  TrackScopedGroupsProvider._({
    required TrackScopedGroupsFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'trackScopedGroupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackScopedGroupsHash();

  @override
  String toString() {
    return r'trackScopedGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Group>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Group>> create(Ref ref) {
    final argument = this.argument as TrackId;
    return trackScopedGroups(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackScopedGroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackScopedGroupsHash() => r'0f7cf26ec55e5ca0444496f076b425badca19e19';

final class TrackScopedGroupsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Group>>, TrackId> {
  TrackScopedGroupsFamily._()
    : super(
        retry: null,
        name: r'trackScopedGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrackScopedGroupsProvider call(TrackId trackId) =>
      TrackScopedGroupsProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackScopedGroupsProvider';
}
