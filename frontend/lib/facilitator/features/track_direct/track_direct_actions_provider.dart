import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/api/ids.dart';
import '../../../shared/api/providers/message_providers.dart';

part 'track_direct_actions_provider.g.dart';

@riverpod
class TrackDirectActions extends _$TrackDirectActions {
  @override
  void build(TrackId trackId) {}

  /// POST /tracks/{trackId}/messages — 발신자 role은 서버가 세션(TrackAuth)으로 판단한다.
  Future<void> send(String content) async {
    final api = ref.read(messageApiProvider);
    await api.tracksTrackIdMessagesPost(
      trackId: trackId.value,
      messagesBroadcastPostRequest: MessagesBroadcastPostRequest((b) => b..content = content),
    );
    ref.invalidate(trackMessageListProvider(trackId));
  }
}
