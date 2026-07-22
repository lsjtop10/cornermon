import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';

part 'track_direct_actions_provider.g.dart';

@riverpod
class TrackDirectActions extends _$TrackDirectActions {
  @override
  void build(TrackId trackId) {}

  /// POST /tracks/{trackId}/messages — 발신자 role은 서버가 세션(TrackAuth)으로 판단한다.
  Future<void> send(String content) async {
    await ref.read(sendDirectMessageProvider(trackId, content).future);
    ref.invalidate(trackMessageListProvider(trackId, background: true));
    ref.invalidate(unreadDirectMessageCountProvider(trackId));
  }
}
