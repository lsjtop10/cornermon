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

String _$visitScanFlowApiHash() => r'cd2237b4e8b458538490fc997a33af81e867aa97';

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
    required ({String? filter, String? sort, String? order}) super.argument,
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
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Group>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Group>> create(Ref ref) {
    final argument =
        this.argument as ({String? filter, String? sort, String? order});
    return groupList(
      ref,
      filter: argument.filter,
      sort: argument.sort,
      order: argument.order,
    );
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

String _$groupListHash() => r'6e320f16f92708161de5605e7c96eb0bfb939e4f';

final class GroupListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Group>>,
          ({String? filter, String? sort, String? order})
        > {
  GroupListFamily._()
    : super(
        retry: null,
        name: r'groupListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupListProvider call({String? filter, String? sort, String? order}) =>
      GroupListProvider._(
        argument: (filter: filter, sort: sort, order: order),
        from: this,
      );

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

String _$groupVisitsHash() => r'8f1761b2361352fb7aa6f137da2492af477c60e8';

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
