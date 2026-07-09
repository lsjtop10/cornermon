// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageApiHash() => r'bced8b39ecff3c0cc84ea1e122742b67fdaf371d';

/// See also [messageApi].
@ProviderFor(messageApi)
final messageApiProvider = AutoDisposeProvider<EMessagesApi>.internal(
  messageApi,
  name: r'messageApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messageApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MessageApiRef = AutoDisposeProviderRef<EMessagesApi>;
String _$broadcastMessageListHash() =>
    r'61db58b6f8a4e9c730ab804861291ae38b001206';

/// See also [broadcastMessageList].
@ProviderFor(broadcastMessageList)
final broadcastMessageListProvider =
    AutoDisposeFutureProvider<List<Message>>.internal(
      broadcastMessageList,
      name: r'broadcastMessageListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$broadcastMessageListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BroadcastMessageListRef = AutoDisposeFutureProviderRef<List<Message>>;
String _$trackMessageListHash() => r'b8eef8069b107bfe9171e40fd35053ee66a53932';

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

/// See also [trackMessageList].
@ProviderFor(trackMessageList)
const trackMessageListProvider = TrackMessageListFamily();

/// See also [trackMessageList].
class TrackMessageListFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [trackMessageList].
  const TrackMessageListFamily();

  /// See also [trackMessageList].
  TrackMessageListProvider call(TrackId trackId) {
    return TrackMessageListProvider(trackId);
  }

  @override
  TrackMessageListProvider getProviderOverride(
    covariant TrackMessageListProvider provider,
  ) {
    return call(provider.trackId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trackMessageListProvider';
}

/// See also [trackMessageList].
class TrackMessageListProvider
    extends AutoDisposeFutureProvider<List<Message>> {
  /// See also [trackMessageList].
  TrackMessageListProvider(TrackId trackId)
    : this._internal(
        (ref) => trackMessageList(ref as TrackMessageListRef, trackId),
        from: trackMessageListProvider,
        name: r'trackMessageListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trackMessageListHash,
        dependencies: TrackMessageListFamily._dependencies,
        allTransitiveDependencies:
            TrackMessageListFamily._allTransitiveDependencies,
        trackId: trackId,
      );

  TrackMessageListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trackId,
  }) : super.internal();

  final TrackId trackId;

  @override
  Override overrideWith(
    FutureOr<List<Message>> Function(TrackMessageListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrackMessageListProvider._internal(
        (ref) => create(ref as TrackMessageListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trackId: trackId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Message>> createElement() {
    return _TrackMessageListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackMessageListProvider && other.trackId == trackId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trackId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrackMessageListRef on AutoDisposeFutureProviderRef<List<Message>> {
  /// The parameter `trackId` of this provider.
  TrackId get trackId;
}

class _TrackMessageListProviderElement
    extends AutoDisposeFutureProviderElement<List<Message>>
    with TrackMessageListRef {
  _TrackMessageListProviderElement(super.provider);

  @override
  TrackId get trackId => (origin as TrackMessageListProvider).trackId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
