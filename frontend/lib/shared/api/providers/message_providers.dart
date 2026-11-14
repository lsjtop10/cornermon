import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';
import 'no_retry.dart';

part 'message_providers.g.dart';

@riverpod
EMessageApi messageApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return EMessageApi(dio, standardSerializers);
}

@riverpod
Future<List<Message>> broadcastMessageList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.campsCampIdMessagesBroadcastGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@Riverpod(retry: noRetry)
Future<Message> sendBroadcastMessage(Ref ref, CampId campId, String content) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.campsCampIdMessagesBroadcastPost(
    campId: campId.value,
    request: BroadcastMessageRequest((b) => b..content = content),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Broadcast message response was empty');
  }
  return data;
}

@Riverpod(retry: noRetry)
Future<void> readBroadcastMessage(Ref ref, MessageId id) async {
  final apiInstance = ref.watch(messageApiProvider);
  await apiInstance.messagesBroadcastIdReadPost(id: id.value);
}

@riverpod
Future<List<BroadcastReceipt>> broadcastReceipts(Ref ref, MessageId id) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.messagesBroadcastIdReceiptsGet(id: id.value);
  return response.data?.toList() ?? [];
}

// 서버의 `background` 쿼리는 "true면 상대측 미확인 메시지를 읽음 처리"한다(GET 부수효과, #277).
// 호출부가 true/false를 직접 고르다 틀리지 않도록 의도별 provider로 나눠 값을 고정한다.
// 두 provider는 서로 다른 캐시이므로 SSE 수신 시 둘 다 invalidate해야 한다.
Future<List<Message>> _fetchTrackMessages(
  Ref ref,
  TrackId trackId, {
  required bool markRead,
}) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.tracksTrackIdMessagesGet(
    trackId: trackId.value,
    background: markRead,
  );
  return response.data?.toList() ?? [];
}

/// 읽음 처리 없는 조회(`background=false`). 알림음 판단, 목록 미리보기처럼
/// 스레드를 "열람"한 게 아닌 곳에서 쓴다. 여기서 읽음 처리하면 도착 즉시 미읽음이 0이 되어
/// 헤더 배지가 뜨지 않는다.
@riverpod
Future<List<Message>> trackMessagePeek(Ref ref, TrackId trackId) =>
    _fetchTrackMessages(ref, trackId, markRead: false);

/// 스레드 열람 조회(`background=true`). 서버에서 상대측 미확인 메시지를 읽음 처리하므로
/// DM 화면이 실제로 열려 있을 때만 쓴다.
@riverpod
Future<List<Message>> trackMessageThread(Ref ref, TrackId trackId) =>
    _fetchTrackMessages(ref, trackId, markRead: true);

@Riverpod(retry: noRetry)
Future<Message> sendDirectMessage(Ref ref, TrackId trackId, String content) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.tracksTrackIdMessagesPost(
    trackId: trackId.value,
    request: DirectMessageRequest((b) => b..content = content),
  );
  final data = response.data;
  if (data == null) {
    throw Exception('Direct message response was empty');
  }
  return data;
}

@riverpod
Future<int> unreadDirectMessageCount(Ref ref, TrackId trackId) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.tracksTrackIdMessagesUnreadCountGet(trackId: trackId.value);
  final data = response.data;
  if (data == null) {
    throw Exception('Unread count response was empty');
  }
  return data.unreadCount ?? 0;
}
