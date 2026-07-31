// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_event_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `TrackEventCoordinator`(`facilitator/features/main_track/track_event_coordinator.dart`)와
/// 대칭되는 admin 쪽 디스패처. 연결상태 자체는 이미 `AdminConnection`
/// (`shared/api/sse/admin_event_stream.dart`)이 관리하므로 여기서 다시 만들지 않고,
/// 이 Notifier는 오직 "이번에 들어온 이벤트를 어떤 화면 provider의 invalidate로 매핑할지"와
/// "재연결 성사 시 전체 재조회"만 담당한다.

@ProviderFor(AdminEventCoordinator)
final adminEventCoordinatorProvider = AdminEventCoordinatorFamily._();

/// `TrackEventCoordinator`(`facilitator/features/main_track/track_event_coordinator.dart`)와
/// 대칭되는 admin 쪽 디스패처. 연결상태 자체는 이미 `AdminConnection`
/// (`shared/api/sse/admin_event_stream.dart`)이 관리하므로 여기서 다시 만들지 않고,
/// 이 Notifier는 오직 "이번에 들어온 이벤트를 어떤 화면 provider의 invalidate로 매핑할지"와
/// "재연결 성사 시 전체 재조회"만 담당한다.
final class AdminEventCoordinatorProvider
    extends $NotifierProvider<AdminEventCoordinator, void> {
  /// `TrackEventCoordinator`(`facilitator/features/main_track/track_event_coordinator.dart`)와
  /// 대칭되는 admin 쪽 디스패처. 연결상태 자체는 이미 `AdminConnection`
  /// (`shared/api/sse/admin_event_stream.dart`)이 관리하므로 여기서 다시 만들지 않고,
  /// 이 Notifier는 오직 "이번에 들어온 이벤트를 어떤 화면 provider의 invalidate로 매핑할지"와
  /// "재연결 성사 시 전체 재조회"만 담당한다.
  AdminEventCoordinatorProvider._({
    required AdminEventCoordinatorFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'adminEventCoordinatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminEventCoordinatorHash();

  @override
  String toString() {
    return r'adminEventCoordinatorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AdminEventCoordinator create() => AdminEventCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdminEventCoordinatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminEventCoordinatorHash() =>
    r'6817c7f6fb7eec2cbcec538e5b019c35c63096de';

/// `TrackEventCoordinator`(`facilitator/features/main_track/track_event_coordinator.dart`)와
/// 대칭되는 admin 쪽 디스패처. 연결상태 자체는 이미 `AdminConnection`
/// (`shared/api/sse/admin_event_stream.dart`)이 관리하므로 여기서 다시 만들지 않고,
/// 이 Notifier는 오직 "이번에 들어온 이벤트를 어떤 화면 provider의 invalidate로 매핑할지"와
/// "재연결 성사 시 전체 재조회"만 담당한다.

final class AdminEventCoordinatorFamily extends $Family
    with $ClassFamilyOverride<AdminEventCoordinator, void, void, void, CampId> {
  AdminEventCoordinatorFamily._()
    : super(
        retry: null,
        name: r'adminEventCoordinatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `TrackEventCoordinator`(`facilitator/features/main_track/track_event_coordinator.dart`)와
  /// 대칭되는 admin 쪽 디스패처. 연결상태 자체는 이미 `AdminConnection`
  /// (`shared/api/sse/admin_event_stream.dart`)이 관리하므로 여기서 다시 만들지 않고,
  /// 이 Notifier는 오직 "이번에 들어온 이벤트를 어떤 화면 provider의 invalidate로 매핑할지"와
  /// "재연결 성사 시 전체 재조회"만 담당한다.

  AdminEventCoordinatorProvider call(CampId campId) =>
      AdminEventCoordinatorProvider._(argument: campId, from: this);

  @override
  String toString() => r'adminEventCoordinatorProvider';
}

/// `TrackEventCoordinator`(`facilitator/features/main_track/track_event_coordinator.dart`)와
/// 대칭되는 admin 쪽 디스패처. 연결상태 자체는 이미 `AdminConnection`
/// (`shared/api/sse/admin_event_stream.dart`)이 관리하므로 여기서 다시 만들지 않고,
/// 이 Notifier는 오직 "이번에 들어온 이벤트를 어떤 화면 provider의 invalidate로 매핑할지"와
/// "재연결 성사 시 전체 재조회"만 담당한다.

abstract class _$AdminEventCoordinator extends $Notifier<void> {
  late final _$args = ref.$arg as CampId;
  CampId get campId => _$args;

  void build(CampId campId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// `ConnectionBanner`(B2 헤더 패턴과 대칭, `shared/design_system/widgets/connection_banner.dart`)에
/// 매핑할 상태. 캠프 미선택 시 SSE 자체가 필요 없는 정상 상태이므로 `hidden`으로 간주한다
/// (배너는 "끊겼을 때만" 뜬다).

@ProviderFor(adminConnectionBannerState)
final adminConnectionBannerStateProvider =
    AdminConnectionBannerStateProvider._();

/// `ConnectionBanner`(B2 헤더 패턴과 대칭, `shared/design_system/widgets/connection_banner.dart`)에
/// 매핑할 상태. 캠프 미선택 시 SSE 자체가 필요 없는 정상 상태이므로 `hidden`으로 간주한다
/// (배너는 "끊겼을 때만" 뜬다).

final class AdminConnectionBannerStateProvider
    extends
        $FunctionalProvider<
          ConnectionBannerState,
          ConnectionBannerState,
          ConnectionBannerState
        >
    with $Provider<ConnectionBannerState> {
  /// `ConnectionBanner`(B2 헤더 패턴과 대칭, `shared/design_system/widgets/connection_banner.dart`)에
  /// 매핑할 상태. 캠프 미선택 시 SSE 자체가 필요 없는 정상 상태이므로 `hidden`으로 간주한다
  /// (배너는 "끊겼을 때만" 뜬다).
  AdminConnectionBannerStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminConnectionBannerStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminConnectionBannerStateHash();

  @$internal
  @override
  $ProviderElement<ConnectionBannerState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectionBannerState create(Ref ref) {
    return adminConnectionBannerState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionBannerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionBannerState>(value),
    );
  }
}

String _$adminConnectionBannerStateHash() =>
    r'7e6f8d561e0a05ce668a1016d3f0b947ac1692cf';
