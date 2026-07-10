// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(messageApi)
final messageApiProvider = MessageApiProvider._();

final class MessageApiProvider
    extends $FunctionalProvider<EMessagesApi, EMessagesApi, EMessagesApi>
    with $Provider<EMessagesApi> {
  MessageApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messageApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messageApiHash();

  @$internal
  @override
  $ProviderElement<EMessagesApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EMessagesApi create(Ref ref) {
    return messageApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EMessagesApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EMessagesApi>(value),
    );
  }
}

String _$messageApiHash() => r'40f5fa823b4679ab9daf049448b5bbe986df1dc3';

@ProviderFor(broadcastMessageList)
final broadcastMessageListProvider = BroadcastMessageListProvider._();

final class BroadcastMessageListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>
        >
    with $FutureModifier<List<Message>>, $FutureProvider<List<Message>> {
  BroadcastMessageListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'broadcastMessageListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$broadcastMessageListHash();

  @$internal
  @override
  $FutureProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Message>> create(Ref ref) {
    return broadcastMessageList(ref);
  }
}

String _$broadcastMessageListHash() =>
    r'47c0528b5146e42e077ad0bf8912398002264f9b';

@ProviderFor(trackMessageList)
final trackMessageListProvider = TrackMessageListFamily._();

final class TrackMessageListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>
        >
    with $FutureModifier<List<Message>>, $FutureProvider<List<Message>> {
  TrackMessageListProvider._({
    required TrackMessageListFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'trackMessageListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackMessageListHash();

  @override
  String toString() {
    return r'trackMessageListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Message>> create(Ref ref) {
    final argument = this.argument as TrackId;
    return trackMessageList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackMessageListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackMessageListHash() => r'25261b62c16ec1deda305ada05730e99783915f4';

final class TrackMessageListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Message>>, TrackId> {
  TrackMessageListFamily._()
    : super(
        retry: null,
        name: r'trackMessageListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrackMessageListProvider call(TrackId trackId) =>
      TrackMessageListProvider._(argument: trackId, from: this);

  @override
  String toString() => r'trackMessageListProvider';
}
