// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(auditLogApi)
final auditLogApiProvider = AuditLogApiProvider._();

final class AuditLogApiProvider
    extends $FunctionalProvider<GAuditLogsApi, GAuditLogsApi, GAuditLogsApi>
    with $Provider<GAuditLogsApi> {
  AuditLogApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditLogApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditLogApiHash();

  @$internal
  @override
  $ProviderElement<GAuditLogsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GAuditLogsApi create(Ref ref) {
    return auditLogApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GAuditLogsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GAuditLogsApi>(value),
    );
  }
}

String _$auditLogApiHash() => r'18b7a25f1b5da08bb78c39d55a71ca88a705e595';

@ProviderFor(auditLogList)
final auditLogListProvider = AuditLogListFamily._();

final class AuditLogListProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuditLogsGet200Response>,
          AuditLogsGet200Response,
          FutureOr<AuditLogsGet200Response>
        >
    with
        $FutureModifier<AuditLogsGet200Response>,
        $FutureProvider<AuditLogsGet200Response> {
  AuditLogListProvider._({
    required AuditLogListFamily super.from,
    required ({int? limit, DateTime? before, String? action, String? actor})
    super.argument,
  }) : super(
         retry: null,
         name: r'auditLogListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$auditLogListHash();

  @override
  String toString() {
    return r'auditLogListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<AuditLogsGet200Response> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AuditLogsGet200Response> create(Ref ref) {
    final argument =
        this.argument
            as ({int? limit, DateTime? before, String? action, String? actor});
    return auditLogList(
      ref,
      limit: argument.limit,
      before: argument.before,
      action: argument.action,
      actor: argument.actor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AuditLogListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$auditLogListHash() => r'3d1e35a98db42f3f7df7a2af9f73e2034553c2cb';

final class AuditLogListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<AuditLogsGet200Response>,
          ({int? limit, DateTime? before, String? action, String? actor})
        > {
  AuditLogListFamily._()
    : super(
        retry: null,
        name: r'auditLogListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuditLogListProvider call({
    int? limit,
    DateTime? before,
    String? action,
    String? actor,
  }) => AuditLogListProvider._(
    argument: (limit: limit, before: before, action: action, actor: actor),
    from: this,
  );

  @override
  String toString() => r'auditLogListProvider';
}
