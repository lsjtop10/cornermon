// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$visitScanFlowApiHash() => r'226aff0e6ebad312f9b8c2eaa3c6a08572945808';

/// See also [visitScanFlowApi].
@ProviderFor(visitScanFlowApi)
final visitScanFlowApiProvider =
    AutoDisposeProvider<CVisitScanFlowApi>.internal(
      visitScanFlowApi,
      name: r'visitScanFlowApiProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$visitScanFlowApiHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VisitScanFlowApiRef = AutoDisposeProviderRef<CVisitScanFlowApi>;
String _$groupListHash() => r'a24c01f357fc547369db3a0730f007ec1148ab41';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [groupList].
@ProviderFor(groupList)
const groupListProvider = GroupListFamily();

/// See also [groupList].
class GroupListFamily extends Family<AsyncValue<List<Group>>> {
  /// See also [groupList].
  const GroupListFamily();

  /// See also [groupList].
  GroupListProvider call({String? filter, String? sort, String? order}) {
    return GroupListProvider(filter: filter, sort: sort, order: order);
  }

  @override
  GroupListProvider getProviderOverride(covariant GroupListProvider provider) {
    return call(
      filter: provider.filter,
      sort: provider.sort,
      order: provider.order,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupListProvider';
}

/// See also [groupList].
class GroupListProvider extends AutoDisposeFutureProvider<List<Group>> {
  /// See also [groupList].
  GroupListProvider({String? filter, String? sort, String? order})
    : this._internal(
        (ref) => groupList(
          ref as GroupListRef,
          filter: filter,
          sort: sort,
          order: order,
        ),
        from: groupListProvider,
        name: r'groupListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupListHash,
        dependencies: GroupListFamily._dependencies,
        allTransitiveDependencies: GroupListFamily._allTransitiveDependencies,
        filter: filter,
        sort: sort,
        order: order,
      );

  GroupListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
    required this.sort,
    required this.order,
  }) : super.internal();

  final String? filter;
  final String? sort;
  final String? order;

  @override
  Override overrideWith(
    FutureOr<List<Group>> Function(GroupListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupListProvider._internal(
        (ref) => create(ref as GroupListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
        sort: sort,
        order: order,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Group>> createElement() {
    return _GroupListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupListProvider &&
        other.filter == filter &&
        other.sort == sort &&
        other.order == order;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);
    hash = _SystemHash.combine(hash, sort.hashCode);
    hash = _SystemHash.combine(hash, order.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupListRef on AutoDisposeFutureProviderRef<List<Group>> {
  /// The parameter `filter` of this provider.
  String? get filter;

  /// The parameter `sort` of this provider.
  String? get sort;

  /// The parameter `order` of this provider.
  String? get order;
}

class _GroupListProviderElement
    extends AutoDisposeFutureProviderElement<List<Group>>
    with GroupListRef {
  _GroupListProviderElement(super.provider);

  @override
  String? get filter => (origin as GroupListProvider).filter;
  @override
  String? get sort => (origin as GroupListProvider).sort;
  @override
  String? get order => (origin as GroupListProvider).order;
}

String _$groupDetailHash() => r'3f594e8678723457f64b25d54f44f59e1bc99cc7';

/// See also [groupDetail].
@ProviderFor(groupDetail)
const groupDetailProvider = GroupDetailFamily();

/// See also [groupDetail].
class GroupDetailFamily extends Family<AsyncValue<Group>> {
  /// See also [groupDetail].
  const GroupDetailFamily();

  /// See also [groupDetail].
  GroupDetailProvider call(GroupId id) {
    return GroupDetailProvider(id);
  }

  @override
  GroupDetailProvider getProviderOverride(
    covariant GroupDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupDetailProvider';
}

/// See also [groupDetail].
class GroupDetailProvider extends AutoDisposeFutureProvider<Group> {
  /// See also [groupDetail].
  GroupDetailProvider(GroupId id)
    : this._internal(
        (ref) => groupDetail(ref as GroupDetailRef, id),
        from: groupDetailProvider,
        name: r'groupDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupDetailHash,
        dependencies: GroupDetailFamily._dependencies,
        allTransitiveDependencies: GroupDetailFamily._allTransitiveDependencies,
        id: id,
      );

  GroupDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final GroupId id;

  @override
  Override overrideWith(
    FutureOr<Group> Function(GroupDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupDetailProvider._internal(
        (ref) => create(ref as GroupDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Group> createElement() {
    return _GroupDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupDetailRef on AutoDisposeFutureProviderRef<Group> {
  /// The parameter `id` of this provider.
  GroupId get id;
}

class _GroupDetailProviderElement
    extends AutoDisposeFutureProviderElement<Group>
    with GroupDetailRef {
  _GroupDetailProviderElement(super.provider);

  @override
  GroupId get id => (origin as GroupDetailProvider).id;
}

String _$groupVisitsHash() => r'defe2c2abaf2c90ca7e260171895bdb65ec9a2f1';

/// See also [groupVisits].
@ProviderFor(groupVisits)
const groupVisitsProvider = GroupVisitsFamily();

/// See also [groupVisits].
class GroupVisitsFamily extends Family<AsyncValue<List<VisitSummary>>> {
  /// See also [groupVisits].
  const GroupVisitsFamily();

  /// See also [groupVisits].
  GroupVisitsProvider call(GroupId id) {
    return GroupVisitsProvider(id);
  }

  @override
  GroupVisitsProvider getProviderOverride(
    covariant GroupVisitsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupVisitsProvider';
}

/// See also [groupVisits].
class GroupVisitsProvider
    extends AutoDisposeFutureProvider<List<VisitSummary>> {
  /// See also [groupVisits].
  GroupVisitsProvider(GroupId id)
    : this._internal(
        (ref) => groupVisits(ref as GroupVisitsRef, id),
        from: groupVisitsProvider,
        name: r'groupVisitsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupVisitsHash,
        dependencies: GroupVisitsFamily._dependencies,
        allTransitiveDependencies: GroupVisitsFamily._allTransitiveDependencies,
        id: id,
      );

  GroupVisitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final GroupId id;

  @override
  Override overrideWith(
    FutureOr<List<VisitSummary>> Function(GroupVisitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupVisitsProvider._internal(
        (ref) => create(ref as GroupVisitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VisitSummary>> createElement() {
    return _GroupVisitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupVisitsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupVisitsRef on AutoDisposeFutureProviderRef<List<VisitSummary>> {
  /// The parameter `id` of this provider.
  GroupId get id;
}

class _GroupVisitsProviderElement
    extends AutoDisposeFutureProviderElement<List<VisitSummary>>
    with GroupVisitsRef {
  _GroupVisitsProviderElement(super.provider);

  @override
  GroupId get id => (origin as GroupVisitsProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
