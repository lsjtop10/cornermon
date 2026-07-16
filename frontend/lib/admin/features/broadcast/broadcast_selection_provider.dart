import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/ids.dart';

part 'broadcast_selection_provider.g.dart';

@riverpod
class SelectedBroadcastId extends _$SelectedBroadcastId {
  @override
  MessageId? build() => null;

  void select(MessageId id) => state = id;
}
