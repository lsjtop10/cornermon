// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_token_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionTokenSource)
final sessionTokenSourceProvider = SessionTokenSourceProvider._();

final class SessionTokenSourceProvider
    extends
        $FunctionalProvider<
          SessionTokenSource,
          SessionTokenSource,
          SessionTokenSource
        >
    with $Provider<SessionTokenSource> {
  SessionTokenSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionTokenSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionTokenSourceHash();

  @$internal
  @override
  $ProviderElement<SessionTokenSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionTokenSource create(Ref ref) {
    return sessionTokenSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionTokenSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionTokenSource>(value),
    );
  }
}

String _$sessionTokenSourceHash() =>
    r'a3fd3b8e33867e5a7faf455420e2a7e4d96369ec';
