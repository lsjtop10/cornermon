// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_feedback.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 무상태 서비스이며 이벤트 코디네이터가 순간적으로 `ref.read`만 하므로,
/// `apiClientProvider`와 동일하게 `keepAlive: true`로 고정한다
/// (frontend/docs/DEVELOPER_GUIDE.md §2.1).

@ProviderFor(noticeFeedback)
final noticeFeedbackProvider = NoticeFeedbackProvider._();

/// 무상태 서비스이며 이벤트 코디네이터가 순간적으로 `ref.read`만 하므로,
/// `apiClientProvider`와 동일하게 `keepAlive: true`로 고정한다
/// (frontend/docs/DEVELOPER_GUIDE.md §2.1).

final class NoticeFeedbackProvider
    extends $FunctionalProvider<NoticeFeedback, NoticeFeedback, NoticeFeedback>
    with $Provider<NoticeFeedback> {
  /// 무상태 서비스이며 이벤트 코디네이터가 순간적으로 `ref.read`만 하므로,
  /// `apiClientProvider`와 동일하게 `keepAlive: true`로 고정한다
  /// (frontend/docs/DEVELOPER_GUIDE.md §2.1).
  NoticeFeedbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noticeFeedbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noticeFeedbackHash();

  @$internal
  @override
  $ProviderElement<NoticeFeedback> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoticeFeedback create(Ref ref) {
    return noticeFeedback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoticeFeedback value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoticeFeedback>(value),
    );
  }
}

String _$noticeFeedbackHash() => r'edb855787f35065359079bf8eb1d76678b0b9f74';
