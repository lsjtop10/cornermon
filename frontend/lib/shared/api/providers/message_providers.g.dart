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
    extends $FunctionalProvider<EMessageApi, EMessageApi, EMessageApi>
    with $Provider<EMessageApi> {
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
  $ProviderElement<EMessageApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EMessageApi create(Ref ref) {
    return messageApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EMessageApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EMessageApi>(value),
    );
  }
}

String _$messageApiHash() => r'bc33ba9f418b6b8926f567782389893c56c1d53a';

@ProviderFor(broadcastMessageList)
final broadcastMessageListProvider = BroadcastMessageListFamily._();

final class BroadcastMessageListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Message>>,
          List<Message>,
          FutureOr<List<Message>>
        >
    with $FutureModifier<List<Message>>, $FutureProvider<List<Message>> {
  BroadcastMessageListProvider._({
    required BroadcastMessageListFamily super.from,
    required CampId super.argument,
  }) : super(
         retry: null,
         name: r'broadcastMessageListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$broadcastMessageListHash();

  @override
  String toString() {
    return r'broadcastMessageListProvider'
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
    final argument = this.argument as CampId;
    return broadcastMessageList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BroadcastMessageListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$broadcastMessageListHash() =>
    r'5ffb583260f4843ab2008af9cd988b535da2e008';

final class BroadcastMessageListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Message>>, CampId> {
  BroadcastMessageListFamily._()
    : super(
        retry: null,
        name: r'broadcastMessageListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BroadcastMessageListProvider call(CampId campId) =>
      BroadcastMessageListProvider._(argument: campId, from: this);

  @override
  String toString() => r'broadcastMessageListProvider';
}

@ProviderFor(sendBroadcastMessage)
final sendBroadcastMessageProvider = SendBroadcastMessageFamily._();

final class SendBroadcastMessageProvider
    extends $FunctionalProvider<AsyncValue<Message>, Message, FutureOr<Message>>
    with $FutureModifier<Message>, $FutureProvider<Message> {
  SendBroadcastMessageProvider._({
    required SendBroadcastMessageFamily super.from,
    required (CampId, String) super.argument,
  }) : super(
         retry: null,
         name: r'sendBroadcastMessageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sendBroadcastMessageHash();

  @override
  String toString() {
    return r'sendBroadcastMessageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Message> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Message> create(Ref ref) {
    final argument = this.argument as (CampId, String);
    return sendBroadcastMessage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SendBroadcastMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sendBroadcastMessageHash() =>
    r'dc9b52ebbc3fbd6a5c6796fe4480a1a576d8a14a';

final class SendBroadcastMessageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Message>, (CampId, String)> {
  SendBroadcastMessageFamily._()
    : super(
        retry: null,
        name: r'sendBroadcastMessageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SendBroadcastMessageProvider call(CampId campId, String content) =>
      SendBroadcastMessageProvider._(argument: (campId, content), from: this);

  @override
  String toString() => r'sendBroadcastMessageProvider';
}

@ProviderFor(readBroadcastMessage)
final readBroadcastMessageProvider = ReadBroadcastMessageFamily._();

final class ReadBroadcastMessageProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  ReadBroadcastMessageProvider._({
    required ReadBroadcastMessageFamily super.from,
    required MessageId super.argument,
  }) : super(
         retry: null,
         name: r'readBroadcastMessageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readBroadcastMessageHash();

  @override
  String toString() {
    return r'readBroadcastMessageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as MessageId;
    return readBroadcastMessage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadBroadcastMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readBroadcastMessageHash() =>
    r'b8388e67780a5fcb8e1012a0c3295cfe4ae61c18';

final class ReadBroadcastMessageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, MessageId> {
  ReadBroadcastMessageFamily._()
    : super(
        retry: null,
        name: r'readBroadcastMessageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReadBroadcastMessageProvider call(MessageId id) =>
      ReadBroadcastMessageProvider._(argument: id, from: this);

  @override
  String toString() => r'readBroadcastMessageProvider';
}

@ProviderFor(broadcastReceipts)
final broadcastReceiptsProvider = BroadcastReceiptsFamily._();

final class BroadcastReceiptsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BroadcastReceipt>>,
          List<BroadcastReceipt>,
          FutureOr<List<BroadcastReceipt>>
        >
    with
        $FutureModifier<List<BroadcastReceipt>>,
        $FutureProvider<List<BroadcastReceipt>> {
  BroadcastReceiptsProvider._({
    required BroadcastReceiptsFamily super.from,
    required MessageId super.argument,
  }) : super(
         retry: null,
         name: r'broadcastReceiptsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$broadcastReceiptsHash();

  @override
  String toString() {
    return r'broadcastReceiptsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BroadcastReceipt>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BroadcastReceipt>> create(Ref ref) {
    final argument = this.argument as MessageId;
    return broadcastReceipts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BroadcastReceiptsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$broadcastReceiptsHash() => r'd9afe2d6a6a46c6ea7503e0cfebec1948f7c790e';

final class BroadcastReceiptsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<BroadcastReceipt>>, MessageId> {
  BroadcastReceiptsFamily._()
    : super(
        retry: null,
        name: r'broadcastReceiptsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BroadcastReceiptsProvider call(MessageId id) =>
      BroadcastReceiptsProvider._(argument: id, from: this);

  @override
  String toString() => r'broadcastReceiptsProvider';
}

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
    required (TrackId, {bool background, DateTime? after}) super.argument,
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
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Message>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Message>> create(Ref ref) {
    final argument =
        this.argument as (TrackId, {bool background, DateTime? after});
    return trackMessageList(
      ref,
      argument.$1,
      background: argument.background,
      after: argument.after,
    );
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

String _$trackMessageListHash() => r'a50a67dcd08517c151d153d96b2f2e08fde2d7ca';

final class TrackMessageListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Message>>,
          (TrackId, {bool background, DateTime? after})
        > {
  TrackMessageListFamily._()
    : super(
        retry: null,
        name: r'trackMessageListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrackMessageListProvider call(
    TrackId trackId, {
    bool background = false,
    DateTime? after,
  }) => TrackMessageListProvider._(
    argument: (trackId, background: background, after: after),
    from: this,
  );

  @override
  String toString() => r'trackMessageListProvider';
}

@ProviderFor(sendDirectMessage)
final sendDirectMessageProvider = SendDirectMessageFamily._();

final class SendDirectMessageProvider
    extends $FunctionalProvider<AsyncValue<Message>, Message, FutureOr<Message>>
    with $FutureModifier<Message>, $FutureProvider<Message> {
  SendDirectMessageProvider._({
    required SendDirectMessageFamily super.from,
    required (TrackId, String) super.argument,
  }) : super(
         retry: null,
         name: r'sendDirectMessageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sendDirectMessageHash();

  @override
  String toString() {
    return r'sendDirectMessageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Message> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Message> create(Ref ref) {
    final argument = this.argument as (TrackId, String);
    return sendDirectMessage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SendDirectMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sendDirectMessageHash() => r'87a8161b7dd20c3a08a62243394826b38af2a261';

final class SendDirectMessageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Message>, (TrackId, String)> {
  SendDirectMessageFamily._()
    : super(
        retry: null,
        name: r'sendDirectMessageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SendDirectMessageProvider call(TrackId trackId, String content) =>
      SendDirectMessageProvider._(argument: (trackId, content), from: this);

  @override
  String toString() => r'sendDirectMessageProvider';
}

@ProviderFor(unreadDirectMessageCount)
final unreadDirectMessageCountProvider = UnreadDirectMessageCountFamily._();

final class UnreadDirectMessageCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  UnreadDirectMessageCountProvider._({
    required UnreadDirectMessageCountFamily super.from,
    required TrackId super.argument,
  }) : super(
         retry: null,
         name: r'unreadDirectMessageCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unreadDirectMessageCountHash();

  @override
  String toString() {
    return r'unreadDirectMessageCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as TrackId;
    return unreadDirectMessageCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadDirectMessageCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadDirectMessageCountHash() =>
    r'b6b1536c0fc142e10c417021d2a6cb137afc9393';

final class UnreadDirectMessageCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, TrackId> {
  UnreadDirectMessageCountFamily._()
    : super(
        retry: null,
        name: r'unreadDirectMessageCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UnreadDirectMessageCountProvider call(TrackId trackId) =>
      UnreadDirectMessageCountProvider._(argument: trackId, from: this);

  @override
  String toString() => r'unreadDirectMessageCountProvider';
}
