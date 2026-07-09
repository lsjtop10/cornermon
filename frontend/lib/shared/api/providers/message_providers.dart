import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import '../client/api_client.dart';
import '../ids.dart';

part 'message_providers.g.dart';

@riverpod
EMessagesApi messageApi(MessageApiRef ref) {
  final dio = ref.watch(apiClientProvider);
  return EMessagesApi(dio, serializers);
}

@riverpod
Future<List<Message>> broadcastMessageList(BroadcastMessageListRef ref) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.messagesBroadcastGet();
  return response.data?.messages?.toList() ?? [];
}

@riverpod
Future<List<Message>> trackMessageList(TrackMessageListRef ref, TrackId trackId) async {
  final apiInstance = ref.watch(messageApiProvider);
  final response = await apiInstance.tracksTrackIdMessagesGet(trackId: trackId.value);
  return response.data?.messages?.toList() ?? [];
}
