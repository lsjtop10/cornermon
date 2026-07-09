// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$badgeListHash() => r'049aa7ca65b56e2d5c47dd9fa24a07cc0ce712f7';

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

/// See also [badgeList].
@ProviderFor(badgeList)
const badgeListProvider = BadgeListFamily();

/// See also [badgeList].
class BadgeListFamily extends Family<AsyncValue<List<Badge>>> {
  /// See also [badgeList].
  const BadgeListFamily();

  /// See also [badgeList].
  BadgeListProvider call({BadgeStatus? status, String? search}) {
    return BadgeListProvider(status: status, search: search);
  }

  @override
  BadgeListProvider getProviderOverride(covariant BadgeListProvider provider) {
    return call(status: provider.status, search: provider.search);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'badgeListProvider';
}

/// See also [badgeList].
class BadgeListProvider extends AutoDisposeFutureProvider<List<Badge>> {
  /// See also [badgeList].
  BadgeListProvider({BadgeStatus? status, String? search})
    : this._internal(
        (ref) => badgeList(ref as BadgeListRef, status: status, search: search),
        from: badgeListProvider,
        name: r'badgeListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$badgeListHash,
        dependencies: BadgeListFamily._dependencies,
        allTransitiveDependencies: BadgeListFamily._allTransitiveDependencies,
        status: status,
        search: search,
      );

  BadgeListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
    required this.search,
  }) : super.internal();

  final BadgeStatus? status;
  final String? search;

  @override
  Override overrideWith(
    FutureOr<List<Badge>> Function(BadgeListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BadgeListProvider._internal(
        (ref) => create(ref as BadgeListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
        search: search,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Badge>> createElement() {
    return _BadgeListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BadgeListProvider &&
        other.status == status &&
        other.search == search;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, search.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BadgeListRef on AutoDisposeFutureProviderRef<List<Badge>> {
  /// The parameter `status` of this provider.
  BadgeStatus? get status;

  /// The parameter `search` of this provider.
  String? get search;
}

class _BadgeListProviderElement
    extends AutoDisposeFutureProviderElement<List<Badge>>
    with BadgeListRef {
  _BadgeListProviderElement(super.provider);

  @override
  BadgeStatus? get status => (origin as BadgeListProvider).status;
  @override
  String? get search => (origin as BadgeListProvider).search;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
