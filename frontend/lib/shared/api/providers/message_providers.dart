import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../domain_aliases.dart';
import '../ids.dart';

part 'message_providers.g.dart';

@riverpod
EMessageApi messageApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return EMessageApi(dio, serializers);
}

@riverpod
Future<List<Message>> broadcastMessageList(Ref ref, CampId campId) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.campsCampIdMessagesBroadcastGet(campId: campId.value);
  return response.data?.toList() ?? [];
}

@riverpod
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

@riverpod
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

@riverpod
Future<List<Message>> trackMessageList(
  Ref ref,
  TrackId trackId, {
  bool background = false,
  DateTime? after,
}) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.tracksTrackIdMessagesGet(
    trackId: trackId.value,
    background: background,
    after: after?.toUtc().toIso8601String(),
  );
  return response.data?.toList() ?? [];
}

@riverpod
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
