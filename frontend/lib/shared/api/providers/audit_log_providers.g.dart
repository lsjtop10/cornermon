// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$auditLogApiHash() => r'f98f72168771923db6f62d7040f6b84fabdb7623';

/// See also [auditLogApi].
@ProviderFor(auditLogApi)
final auditLogApiProvider = AutoDisposeProvider<GAuditLogsApi>.internal(
  auditLogApi,
  name: r'auditLogApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$auditLogApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuditLogApiRef = AutoDisposeProviderRef<GAuditLogsApi>;
String _$auditLogListHash() => r'86f53eb777921f398dc11273dabd6ce70620421c';

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

/// See also [auditLogList].
@ProviderFor(auditLogList)
const auditLogListProvider = AuditLogListFamily();

/// See also [auditLogList].
class AuditLogListFamily extends Family<AsyncValue<AuditLogsGet200Response>> {
  /// See also [auditLogList].
  const AuditLogListFamily();

  /// See also [auditLogList].
  AuditLogListProvider call({
    int? limit,
    DateTime? before,
    String? action,
    String? actor,
  }) {
    return AuditLogListProvider(
      limit: limit,
      before: before,
      action: action,
      actor: actor,
    );
  }

  @override
  AuditLogListProvider getProviderOverride(
    covariant AuditLogListProvider provider,
  ) {
    return call(
      limit: provider.limit,
      before: provider.before,
      action: provider.action,
      actor: provider.actor,
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
  String? get name => r'auditLogListProvider';
}

/// See also [auditLogList].
class AuditLogListProvider
    extends AutoDisposeFutureProvider<AuditLogsGet200Response> {
  /// See also [auditLogList].
  AuditLogListProvider({
    int? limit,
    DateTime? before,
    String? action,
    String? actor,
  }) : this._internal(
         (ref) => auditLogList(
           ref as AuditLogListRef,
           limit: limit,
           before: before,
           action: action,
           actor: actor,
         ),
         from: auditLogListProvider,
         name: r'auditLogListProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$auditLogListHash,
         dependencies: AuditLogListFamily._dependencies,
         allTransitiveDependencies:
             AuditLogListFamily._allTransitiveDependencies,
         limit: limit,
         before: before,
         action: action,
         actor: actor,
       );

  AuditLogListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.before,
    required this.action,
    required this.actor,
  }) : super.internal();

  final int? limit;
  final DateTime? before;
  final String? action;
  final String? actor;

  @override
  Override overrideWith(
    FutureOr<AuditLogsGet200Response> Function(AuditLogListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AuditLogListProvider._internal(
        (ref) => create(ref as AuditLogListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        before: before,
        action: action,
        actor: actor,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AuditLogsGet200Response> createElement() {
    return _AuditLogListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuditLogListProvider &&
        other.limit == limit &&
        other.before == before &&
        other.action == action &&
        other.actor == actor;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, before.hashCode);
    hash = _SystemHash.combine(hash, action.hashCode);
    hash = _SystemHash.combine(hash, actor.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AuditLogListRef on AutoDisposeFutureProviderRef<AuditLogsGet200Response> {
  /// The parameter `limit` of this provider.
  int? get limit;

  /// The parameter `before` of this provider.
  DateTime? get before;

  /// The parameter `action` of this provider.
  String? get action;

  /// The parameter `actor` of this provider.
  String? get actor;
}

class _AuditLogListProviderElement
    extends AutoDisposeFutureProviderElement<AuditLogsGet200Response>
    with AuditLogListRef {
  _AuditLogListProviderElement(super.provider);

  @override
  int? get limit => (origin as AuditLogListProvider).limit;
  @override
  DateTime? get before => (origin as AuditLogListProvider).before;
  @override
  String? get action => (origin as AuditLogListProvider).action;
  @override
  String? get actor => (origin as AuditLogListProvider).actor;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
