import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'track_session_provider.dart';

part 'facilitator_broadcast_provider.g.dart';

/// 인증된 진행자 세션에서 공지 목록 조회에 쓸 캠프 범위를 구한다.
///
/// 화면과 SSE coordinator가 같은 family instance를 invalidate해야 하므로, campId 변환은
/// provider 내부에 숨기지 않고 이 순수 함수로 공유한다.
CampId? facilitatorBroadcastCampId(TrackSessionState session) {
  if (session is! TrackSessionAuthenticated) return null;

  final campId = session.corner.campId;
  return campId == null ? null : CampId(campId);
}

/// campId를 인자로 받아야 하는 [broadcastMessageListProvider]를, 진행자 화면이 써온
/// 인자 없는 형태로 다리 놓는다. campId는 별도로 영속화하지 않고 인증된 트랙 세션의
/// corner.campId를 그대로 쓴다 — 세션이 곧 그 캠프에 속한다는 증거이므로 항상 최신이다.
@riverpod
Future<List<Message>> facilitatorBroadcastMessageList(Ref ref) async {
  final session = ref.watch(trackSessionProvider);
  final campId = facilitatorBroadcastCampId(session);
  if (campId == null) return [];

  return ref.watch(broadcastMessageListProvider(campId).future);
}
