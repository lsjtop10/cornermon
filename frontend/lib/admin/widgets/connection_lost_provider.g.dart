// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_lost_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 화면별 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.
///
/// [scope]는 화면을 구분하는 키로, 화면마다 값이 독립적이다(예: 'admin_management',
/// 'device_manage', 'dashboard').

@ProviderFor(ConnectionLost)
final connectionLostProvider = ConnectionLostFamily._();

/// 화면별 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.
///
/// [scope]는 화면을 구분하는 키로, 화면마다 값이 독립적이다(예: 'admin_management',
/// 'device_manage', 'dashboard').
final class ConnectionLostProvider
    extends $NotifierProvider<ConnectionLost, bool> {
  /// 화면별 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
  /// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
  /// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
  /// isConnectionLost 참고.
  ///
  /// [scope]는 화면을 구분하는 키로, 화면마다 값이 독립적이다(예: 'admin_management',
  /// 'device_manage', 'dashboard').
  ConnectionLostProvider._({
    required ConnectionLostFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'connectionLostProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$connectionLostHash();

  @override
  String toString() {
    return r'connectionLostProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConnectionLost create() => ConnectionLost();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectionLostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$connectionLostHash() => r'894d53b0ff874065823dae4e9e7f92763f53d685';

/// 화면별 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.
///
/// [scope]는 화면을 구분하는 키로, 화면마다 값이 독립적이다(예: 'admin_management',
/// 'device_manage', 'dashboard').

final class ConnectionLostFamily extends $Family
    with $ClassFamilyOverride<ConnectionLost, bool, bool, bool, String> {
  ConnectionLostFamily._()
    : super(
        retry: null,
        name: r'connectionLostProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 화면별 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
  /// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
  /// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
  /// isConnectionLost 참고.
  ///
  /// [scope]는 화면을 구분하는 키로, 화면마다 값이 독립적이다(예: 'admin_management',
  /// 'device_manage', 'dashboard').

  ConnectionLostProvider call(String scope) =>
      ConnectionLostProvider._(argument: scope, from: this);

  @override
  String toString() => r'connectionLostProvider';
}

/// 화면별 액션이 커넥션 유실(타임아웃 등, 서버 응답 자체를 못 받음)로 실패했을 때
/// 화면 상단 배너로 표시하기 위한 상태. API 호출 에러(서버가 응답한 4xx/5xx) 및 그 외
/// 에러는 SnackBar로 개별 표시하므로 여기 포함하지 않는다 — dio_error.dart의
/// isConnectionLost 참고.
///
/// [scope]는 화면을 구분하는 키로, 화면마다 값이 독립적이다(예: 'admin_management',
/// 'device_manage', 'dashboard').

abstract class _$ConnectionLost extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get scope => _$args;

  bool build(String scope);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
