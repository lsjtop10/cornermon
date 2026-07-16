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

String _$auditLogApiHash() => r'46f8bccb1a2d7df04714979386a8f463036699b3';

@ProviderFor(auditLogList)
final auditLogListProvider = AuditLogListFamily._();

final class AuditLogListProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuditLogPage>,
          AuditLogPage,
          FutureOr<AuditLogPage>
        >
    with $FutureModifier<AuditLogPage>, $FutureProvider<AuditLogPage> {
  AuditLogListProvider._({
    required AuditLogListFamily super.from,
    required ({
      int? limit,
      String? before,
      String? action,
      String? actor,
      String? result,
    })
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
  $FutureProviderElement<AuditLogPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AuditLogPage> create(Ref ref) {
    final argument =
        this.argument
            as ({
              int? limit,
              String? before,
              String? action,
              String? actor,
              String? result,
            });
    return auditLogList(
      ref,
      limit: argument.limit,
      before: argument.before,
      action: argument.action,
      actor: argument.actor,
      result: argument.result,
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

String _$auditLogListHash() => r'd2eb0ac65c0a2a09092ebab0b3b1590162d8f7ac';

final class AuditLogListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<AuditLogPage>,
          ({
            int? limit,
            String? before,
            String? action,
            String? actor,
            String? result,
          })
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
    String? before,
    String? action,
    String? actor,
    String? result,
  }) => AuditLogListProvider._(
    argument: (
      limit: limit,
      before: before,
      action: action,
      actor: actor,
      result: result,
    ),
    from: this,
  );

  @override
  String toString() => r'auditLogListProvider';
}
