// GENERATED CODE - DO NOT MODIFY BY HAND

part of '_track_bulk_manage_connection_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 코너 삭제 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.

@ProviderFor(TrackBulkManageConnectionLost)
final trackBulkManageConnectionLostProvider =
    TrackBulkManageConnectionLostProvider._();

/// 코너 삭제 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.
final class TrackBulkManageConnectionLostProvider
    extends $NotifierProvider<TrackBulkManageConnectionLost, bool> {
  /// 코너 삭제 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
  /// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
  /// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
  /// isConnectionLost 참고.
  TrackBulkManageConnectionLostProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackBulkManageConnectionLostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackBulkManageConnectionLostHash();

  @$internal
  @override
  TrackBulkManageConnectionLost create() => TrackBulkManageConnectionLost();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$trackBulkManageConnectionLostHash() =>
    r'578bbaa3b01b17203e14558c372f5edbfd891671';

/// 코너 삭제 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.

abstract class _$TrackBulkManageConnectionLost extends $Notifier<bool> {
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
