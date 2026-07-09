// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corner_track_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cornerListHash() => r'3224e27cdea83caa1becca483b2e3c7debf0c617';

/// See also [cornerList].
@ProviderFor(cornerList)
final cornerListProvider = AutoDisposeFutureProvider<List<Corner>>.internal(
  cornerList,
  name: r'cornerListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cornerListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CornerListRef = AutoDisposeFutureProviderRef<List<Corner>>;
String _$cornerDetailHash() => r'44028c0ad589690a83ae5b96507cd2cb7931f853';

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

/// See also [cornerDetail].
@ProviderFor(cornerDetail)
const cornerDetailProvider = CornerDetailFamily();

/// See also [cornerDetail].
class CornerDetailFamily extends Family<AsyncValue<Corner>> {
  /// See also [cornerDetail].
  const CornerDetailFamily();

  /// See also [cornerDetail].
  CornerDetailProvider call(CornerId id) {
    return CornerDetailProvider(id);
  }

  @override
  CornerDetailProvider getProviderOverride(
    covariant CornerDetailProvider provider,
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
  String? get name => r'cornerDetailProvider';
}

/// See also [cornerDetail].
class CornerDetailProvider extends AutoDisposeFutureProvider<Corner> {
  /// See also [cornerDetail].
  CornerDetailProvider(CornerId id)
    : this._internal(
        (ref) => cornerDetail(ref as CornerDetailRef, id),
        from: cornerDetailProvider,
        name: r'cornerDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cornerDetailHash,
        dependencies: CornerDetailFamily._dependencies,
        allTransitiveDependencies:
            CornerDetailFamily._allTransitiveDependencies,
        id: id,
      );

  CornerDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final CornerId id;

  @override
  Override overrideWith(
    FutureOr<Corner> Function(CornerDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CornerDetailProvider._internal(
        (ref) => create(ref as CornerDetailRef),
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
  AutoDisposeFutureProviderElement<Corner> createElement() {
    return _CornerDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CornerDetailProvider && other.id == id;
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
mixin CornerDetailRef on AutoDisposeFutureProviderRef<Corner> {
  /// The parameter `id` of this provider.
  CornerId get id;
}

class _CornerDetailProviderElement
    extends AutoDisposeFutureProviderElement<Corner>
    with CornerDetailRef {
  _CornerDetailProviderElement(super.provider);

  @override
  CornerId get id => (origin as CornerDetailProvider).id;
}

String _$trackListHash() => r'3919830a42fe56c549a837bd39bb6fd440d87de0';

/// See also [trackList].
@ProviderFor(trackList)
final trackListProvider = AutoDisposeFutureProvider<List<Track>>.internal(
  trackList,
  name: r'trackListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trackListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrackListRef = AutoDisposeFutureProviderRef<List<Track>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
