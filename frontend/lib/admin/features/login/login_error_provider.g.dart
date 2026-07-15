// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_error_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 로그인 화면에만 필요한 일시적인 오류 상태다.

@ProviderFor(LoginError)
final loginErrorProvider = LoginErrorProvider._();

/// 로그인 화면에만 필요한 일시적인 오류 상태다.
final class LoginErrorProvider
    extends $NotifierProvider<LoginError, AdminLoginUiError?> {
  /// 로그인 화면에만 필요한 일시적인 오류 상태다.
  LoginErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginErrorHash();

  @$internal
  @override
  LoginError create() => LoginError();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminLoginUiError? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminLoginUiError?>(value),
    );
  }
}

String _$loginErrorHash() => r'9eb624ad2ca8d47423dd8e586f483152c660542b';

/// 로그인 화면에만 필요한 일시적인 오류 상태다.

abstract class _$LoginError extends $Notifier<AdminLoginUiError?> {
  AdminLoginUiError? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdminLoginUiError?, AdminLoginUiError?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminLoginUiError?, AdminLoginUiError?>,
              AdminLoginUiError?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
