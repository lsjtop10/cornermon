// GENERATED CODE - DO NOT MODIFY BY HAND

part of '_dashboard_connection_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 코너 추가/삭제가 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태 — `_device_manage_connection_state.dart`와
/// 동일한 패턴. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로
/// 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의 isConnectionLost 참고.
///
/// 앱 전역 SSE 연결 상태(재연결 중/끊김)는 이미 `admin/app.dart`가
/// `adminConnectionBannerStateProvider`로 모든 화면 위에 공통 배너를 띄우고 있다 —
/// 이 provider는 그것과 별개로, 이 화면의 코너 CRUD 액션 하나가 커넥션 유실로
/// 실패했을 때의 즉각적인 신호만 담당한다.

@ProviderFor(DashboardConnectionLost)
final dashboardConnectionLostProvider = DashboardConnectionLostProvider._();

/// 코너 추가/삭제가 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태 — `_device_manage_connection_state.dart`와
/// 동일한 패턴. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로
/// 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의 isConnectionLost 참고.
///
/// 앱 전역 SSE 연결 상태(재연결 중/끊김)는 이미 `admin/app.dart`가
/// `adminConnectionBannerStateProvider`로 모든 화면 위에 공통 배너를 띄우고 있다 —
/// 이 provider는 그것과 별개로, 이 화면의 코너 CRUD 액션 하나가 커넥션 유실로
/// 실패했을 때의 즉각적인 신호만 담당한다.
final class DashboardConnectionLostProvider
    extends $NotifierProvider<DashboardConnectionLost, bool> {
  /// 코너 추가/삭제가 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
  /// 화면 상단 배너로 표시하기 위한 상태 — `_device_manage_connection_state.dart`와
  /// 동일한 패턴. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로
  /// 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의 isConnectionLost 참고.
  ///
  /// 앱 전역 SSE 연결 상태(재연결 중/끊김)는 이미 `admin/app.dart`가
  /// `adminConnectionBannerStateProvider`로 모든 화면 위에 공통 배너를 띄우고 있다 —
  /// 이 provider는 그것과 별개로, 이 화면의 코너 CRUD 액션 하나가 커넥션 유실로
  /// 실패했을 때의 즉각적인 신호만 담당한다.
  DashboardConnectionLostProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardConnectionLostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardConnectionLostHash();

  @$internal
  @override
  DashboardConnectionLost create() => DashboardConnectionLost();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$dashboardConnectionLostHash() =>
    r'0000000000000000000000000000000000000a';

/// 코너 추가/삭제가 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태 — `_device_manage_connection_state.dart`와
/// 동일한 패턴. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로
/// 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의 isConnectionLost 참고.
///
/// 앱 전역 SSE 연결 상태(재연결 중/끊김)는 이미 `admin/app.dart`가
/// `adminConnectionBannerStateProvider`로 모든 화면 위에 공통 배너를 띄우고 있다 —
/// 이 provider는 그것과 별개로, 이 화면의 코너 CRUD 액션 하나가 커넥션 유실로
/// 실패했을 때의 즉각적인 신호만 담당한다.

abstract class _$DashboardConnectionLost extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
