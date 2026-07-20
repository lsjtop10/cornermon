// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_event_stream.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminConnection)
final adminConnectionProvider = AdminConnectionFamily._();

final class AdminConnectionProvider
    extends $NotifierProvider<AdminConnection, AdminConnectionState> {
  AdminConnectionProvider._({
    required AdminConnectionFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'adminConnectionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminConnectionHash();

  @override
  String toString() {
    return r'adminConnectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AdminConnection create() => AdminConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminConnectionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdminConnectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminConnectionHash() => r'ab9f26a07a852f4fb710de8d5129f60994b2cc4c';

final class AdminConnectionFamily extends $Family
    with
        $ClassFamilyOverride<
          AdminConnection,
          AdminConnectionState,
          AdminConnectionState,
          AdminConnectionState,
          CampId
        > {
  AdminConnectionFamily._()
    : super(
        retry: null,
        name: r'adminConnectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AdminConnectionProvider call(CampId campId) =>
      AdminConnectionProvider._(argument: campId, from: this);

  @override
  String toString() => r'adminConnectionProvider';
}

abstract class _$AdminConnection extends $Notifier<AdminConnectionState> {
  late final _$args = ref.$arg as CampId;
  CampId get campId => _$args;

  AdminConnectionState build(CampId campId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdminConnectionState, AdminConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminConnectionState, AdminConnectionState>,
              AdminConnectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(adminEvents)
final adminEventsProvider = AdminEventsFamily._();

final class AdminEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SSENotification>,
          SSENotification,
          Stream<SSENotification>
        >
    with $FutureModifier<SSENotification>, $StreamProvider<SSENotification> {
  AdminEventsProvider._({
    required AdminEventsFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'adminEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminEventsHash();

  @override
  String toString() {
    return r'adminEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SSENotification> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SSENotification> create(Ref ref) {
    final argument = this.argument as CampId;
    return adminEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminEventsHash() => r'bec489d99a5a5a2d3f00c030966632b201e1c4b4';

final class AdminEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SSENotification>, CampId> {
  AdminEventsFamily._()
    : super(
        retry: null,
        name: r'adminEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminEventsProvider call(CampId campId) =>
      AdminEventsProvider._(argument: campId, from: this);

  @override
  String toString() => r'adminEventsProvider';
}
