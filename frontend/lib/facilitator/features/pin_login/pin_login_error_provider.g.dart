// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_login_error_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PinLoginError)
final pinLoginErrorProvider = PinLoginErrorProvider._();

final class PinLoginErrorProvider
    extends $NotifierProvider<PinLoginError, PinLoginUiError?> {
  PinLoginErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinLoginErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinLoginErrorHash();

  @$internal
  @override
  PinLoginError create() => PinLoginError();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinLoginUiError? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinLoginUiError?>(value),
    );
  }
}

String _$pinLoginErrorHash() => r'4a03372f47ad6502a8a4a29fc4d1e1edc69f5944';

abstract class _$PinLoginError extends $Notifier<PinLoginUiError?> {
  PinLoginUiError? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PinLoginUiError?, PinLoginUiError?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PinLoginUiError?, PinLoginUiError?>,
              PinLoginUiError?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
