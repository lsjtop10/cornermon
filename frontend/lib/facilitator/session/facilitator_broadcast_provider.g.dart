// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facilitator_broadcast_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// campId를 인자로 받아야 하는 [broadcastMessageListProvider]를, 진행자 화면이 써온
/// 인자 없는 형태로 다리 놓는다. campId는 별도로 영속화하지 않고 인증된 트랙 세션의
/// corner.campId를 그대로 쓴다 — 세션이 곧 그 캠프에 속한다는 증거이므로 항상 최신이다.

@ProviderFor(facilitatorBroadcastMessageList)
final facilitatorBroadcastMessageListProvider =
    FacilitatorBroadcastMessageListProvider._();

/// campId를 인자로 받아야 하는 [broadcastMessageListProvider]를, 진행자 화면이 써온
/// 인자 없는 형태로 다리 놓는다. campId는 별도로 영속화하지 않고 인증된 트랙 세션의
/// corner.campId를 그대로 쓴다 — 세션이 곧 그 캠프에 속한다는 증거이므로 항상 최신이다.

final class FacilitatorBroadcastMessageListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>
        >
    with $FutureModifier<List<Message>>, $FutureProvider<List<Message>> {
  /// campId를 인자로 받아야 하는 [broadcastMessageListProvider]를, 진행자 화면이 써온
  /// 인자 없는 형태로 다리 놓는다. campId는 별도로 영속화하지 않고 인증된 트랙 세션의
  /// corner.campId를 그대로 쓴다 — 세션이 곧 그 캠프에 속한다는 증거이므로 항상 최신이다.
  FacilitatorBroadcastMessageListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facilitatorBroadcastMessageListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facilitatorBroadcastMessageListHash();

  @$internal
  @override
  $FutureProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Message>> create(Ref ref) {
    return facilitatorBroadcastMessageList(ref);
  }
}

String _$facilitatorBroadcastMessageListHash() =>
    r'8c2465a5285f4fa3940ac2ee38d83104a5fef291';
