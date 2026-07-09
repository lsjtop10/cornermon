// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camp_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$campApiHash() => r'9e43a92deba9f5cc68f47b0f993d104fc89f9cc8';

/// See also [campApi].
@ProviderFor(campApi)
final campApiProvider = AutoDisposeProvider<BCampCornerTrackApi>.internal(
  campApi,
  name: r'campApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$campApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CampApiRef = AutoDisposeProviderRef<BCampCornerTrackApi>;
String _$campListHash() => r'a1080babedc675f9d526c63167502b32226ba29e';

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

/// See also [campList].
@ProviderFor(campList)
const campListProvider = CampListFamily();

/// See also [campList].
class CampListFamily extends Family<AsyncValue<List<Camp>>> {
  /// See also [campList].
  const CampListFamily();

  /// See also [campList].
  CampListProvider call({CampStatus? status}) {
    return CampListProvider(status: status);
  }

  @override
  CampListProvider getProviderOverride(covariant CampListProvider provider) {
    return call(status: provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'campListProvider';
}

/// See also [campList].
class CampListProvider extends AutoDisposeFutureProvider<List<Camp>> {
  /// See also [campList].
  CampListProvider({CampStatus? status})
    : this._internal(
        (ref) => campList(ref as CampListRef, status: status),
        from: campListProvider,
        name: r'campListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$campListHash,
        dependencies: CampListFamily._dependencies,
        allTransitiveDependencies: CampListFamily._allTransitiveDependencies,
        status: status,
      );

  CampListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final CampStatus? status;

  @override
  Override overrideWith(
    FutureOr<List<Camp>> Function(CampListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CampListProvider._internal(
        (ref) => create(ref as CampListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Camp>> createElement() {
    return _CampListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CampListProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CampListRef on AutoDisposeFutureProviderRef<List<Camp>> {
  /// The parameter `status` of this provider.
  CampStatus? get status;
}

class _CampListProviderElement
    extends AutoDisposeFutureProviderElement<List<Camp>>
    with CampListRef {
  _CampListProviderElement(super.provider);

  @override
  CampStatus? get status => (origin as CampListProvider).status;
}

String _$campDetailHash() => r'1763f5748f17f28e1a17e19ca8f295e1a1598c6c';

/// See also [campDetail].
@ProviderFor(campDetail)
const campDetailProvider = CampDetailFamily();

/// See also [campDetail].
class CampDetailFamily extends Family<AsyncValue<Camp>> {
  /// See also [campDetail].
  const CampDetailFamily();

  /// See also [campDetail].
  CampDetailProvider call(CampId id) {
    return CampDetailProvider(id);
  }

  @override
  CampDetailProvider getProviderOverride(
    covariant CampDetailProvider provider,
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
  String? get name => r'campDetailProvider';
}

/// See also [campDetail].
class CampDetailProvider extends AutoDisposeFutureProvider<Camp> {
  /// See also [campDetail].
  CampDetailProvider(CampId id)
    : this._internal(
        (ref) => campDetail(ref as CampDetailRef, id),
        from: campDetailProvider,
        name: r'campDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$campDetailHash,
        dependencies: CampDetailFamily._dependencies,
        allTransitiveDependencies: CampDetailFamily._allTransitiveDependencies,
        id: id,
      );

  CampDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final CampId id;

  @override
  Override overrideWith(
    FutureOr<Camp> Function(CampDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CampDetailProvider._internal(
        (ref) => create(ref as CampDetailRef),
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
  AutoDisposeFutureProviderElement<Camp> createElement() {
    return _CampDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CampDetailProvider && other.id == id;
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
mixin CampDetailRef on AutoDisposeFutureProviderRef<Camp> {
  /// The parameter `id` of this provider.
  CampId get id;
}

class _CampDetailProviderElement extends AutoDisposeFutureProviderElement<Camp>
    with CampDetailRef {
  _CampDetailProviderElement(super.provider);

  @override
  CampId get id => (origin as CampDetailProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
