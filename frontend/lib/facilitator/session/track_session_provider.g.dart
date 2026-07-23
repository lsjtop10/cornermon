// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// migrate-session(POST /tracks/{id}/migrate-session)만 쓰는 전용 클라이언트다.
/// 이 오퍼레이션만 `BCampCornerTrackApi`(swagger 태그가 다른 트랙/코너 CRUD API와 갈려서
/// 별도 클래스로 생성됨)에 속해 있어, 다른 트랙 세션 API처럼 authDeviceTrustApiProvider에
/// 얹을 수 없다.

@ProviderFor(trackMigrationApi)
final trackMigrationApiProvider = TrackMigrationApiProvider._();

/// migrate-session(POST /tracks/{id}/migrate-session)만 쓰는 전용 클라이언트다.
/// 이 오퍼레이션만 `BCampCornerTrackApi`(swagger 태그가 다른 트랙/코너 CRUD API와 갈려서
/// 별도 클래스로 생성됨)에 속해 있어, 다른 트랙 세션 API처럼 authDeviceTrustApiProvider에
/// 얹을 수 없다.

final class TrackMigrationApiProvider
    extends
        $FunctionalProvider<
          BCampCornerTrackApi,
          BCampCornerTrackApi,
          BCampCornerTrackApi
        >
    with $Provider<BCampCornerTrackApi> {
  /// migrate-session(POST /tracks/{id}/migrate-session)만 쓰는 전용 클라이언트다.
  /// 이 오퍼레이션만 `BCampCornerTrackApi`(swagger 태그가 다른 트랙/코너 CRUD API와 갈려서
  /// 별도 클래스로 생성됨)에 속해 있어, 다른 트랙 세션 API처럼 authDeviceTrustApiProvider에
  /// 얹을 수 없다.
  TrackMigrationApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackMigrationApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackMigrationApiHash();

  @$internal
  @override
  $ProviderElement<BCampCornerTrackApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BCampCornerTrackApi create(Ref ref) {
    return trackMigrationApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BCampCornerTrackApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BCampCornerTrackApi>(value),
    );
  }
}

String _$trackMigrationApiHash() => r'ec82c590b74d7d24be20b2dfc05ffdeca8adf322';

@ProviderFor(TrackSession)
final trackSessionProvider = TrackSessionProvider._();

final class TrackSessionProvider
    extends $NotifierProvider<TrackSession, TrackSessionState> {
  TrackSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackSessionHash();

  @$internal
  @override
  TrackSession create() => TrackSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackSessionState>(value),
    );
  }
}

String _$trackSessionHash() => r'62c88d03af04ddb8e7040f0ab4e692541c75ea95';

abstract class _$TrackSession extends $Notifier<TrackSessionState> {
  TrackSessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TrackSessionState, TrackSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrackSessionState, TrackSessionState>,
              TrackSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
