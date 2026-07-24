// GENERATED CODE - DO NOT MODIFY BY HAND

part of '_admin_management_connection_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 목록 조회/추가/삭제/비밀번호 변경/탈퇴 액션이 커넥션 유실(타임아웃 등, 서버 응답
/// 자체를 못 받음)로 실패했을 때 화면 상단 배너로 표시하기 위한 상태. API 호출 에러
/// (서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로 개별 표시하므로 여기 포함하지
/// 않는다 — dio_error.dart의 isConnectionLost 참고.

@ProviderFor(AdminManagementConnectionLost)
final adminManagementConnectionLostProvider =
    AdminManagementConnectionLostProvider._();

/// 목록 조회/추가/삭제/비밀번호 변경/탈퇴 액션이 커넥션 유실(타임아웃 등, 서버 응답
/// 자체를 못 받음)로 실패했을 때 화면 상단 배너로 표시하기 위한 상태. API 호출 에러
/// (서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로 개별 표시하므로 여기 포함하지
/// 않는다 — dio_error.dart의 isConnectionLost 참고.
final class AdminManagementConnectionLostProvider
    extends $NotifierProvider<AdminManagementConnectionLost, bool> {
  /// 목록 조회/추가/삭제/비밀번호 변경/탈퇴 액션이 커넥션 유실(타임아웃 등, 서버 응답
  /// 자체를 못 받음)로 실패했을 때 화면 상단 배너로 표시하기 위한 상태. API 호출 에러
  /// (서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로 개별 표시하므로 여기 포함하지
  /// 않는다 — dio_error.dart의 isConnectionLost 참고.
  AdminManagementConnectionLostProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminManagementConnectionLostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminManagementConnectionLostHash();

  @$internal
  @override
  AdminManagementConnectionLost create() => AdminManagementConnectionLost();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adminManagementConnectionLostHash() =>
    r'c34364df838d80ddc92e8eab7dd2354e0f24f5bf';

/// 목록 조회/추가/삭제/비밀번호 변경/탈퇴 액션이 커넥션 유실(타임아웃 등, 서버 응답
/// 자체를 못 받음)로 실패했을 때 화면 상단 배너로 표시하기 위한 상태. API 호출 에러
/// (서버가 응답한 4xx/5xx) 및 그 외 에러는 SnackBar로 개별 표시하므로 여기 포함하지
/// 않는다 — dio_error.dart의 isConnectionLost 참고.

abstract class _$AdminManagementConnectionLost extends $Notifier<bool> {
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
