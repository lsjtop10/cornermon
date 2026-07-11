import 'package:cornermon/facilitator/features/broadcast_inbox/broadcast_inbox_screen.dart';
import 'package:cornermon/facilitator/widgets/local_time_label.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/widget_test_helpers.dart';

/// 읽음 처리 POST 호출만 기록하는 가짜 구현 — 다른 메서드는 이 테스트에서 호출되지 않는다.
class _FakeMessagesApi extends EMessagesApi {
  _FakeMessagesApi() : super(Dio(), serializers);

  final List<String> readCalledIds = [];

  @override
  Future<Response<void>> messagesBroadcastIdReadPost({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    readCalledIds.add(id);
    return Response<void>(requestOptions: RequestOptions(path: '/messages/broadcast/$id/read'));
  }
}

Message _buildMessage({
  required String id,
  required String content,
  DateTime? sentAt,
  DateTime? readAt,
}) {
  return Message(
    (b) => b
      ..id = id
      ..channelType = MessageChannelType.BROADCAST
      ..senderRole = MessageSenderRoleEnum.ADMIN
      ..content = content
      ..sentAt = sentAt ?? DateTime.utc(2026, 7, 10, 3, 0, 0)
      ..readAt = readAt,
  );
}

void main() {
  testWidgets('ShouldRenderUnreadMessagesBold', (tester) async {
    // arrange
    final unread = _buildMessage(id: 'm-1', content: '안읽은 공지');
    final read = _buildMessage(
      id: 'm-2',
      content: '읽은 공지',
      readAt: DateTime.utc(2026, 7, 10, 4, 0, 0),
    );
    final fakeApi = _FakeMessagesApi();

    // act
    await tester.pumpWidget(
      buildTestable(
        const BroadcastInboxScreen(),
        overrides: [
          broadcastMessageListProvider.overrideWith((ref) => [unread, read]),
          messageApiProvider.overrideWithValue(fakeApi),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // assert
    final unreadStyle = tester.widget<Text>(find.text('안읽은 공지')).style;
    final readStyle = tester.widget<Text>(find.text('읽은 공지')).style;
    expect(unreadStyle?.fontWeight, FontWeight.bold);
    expect(readStyle?.fontWeight, FontWeight.normal);
  });

  testWidgets('ShouldCallReadEndpointOnlyForUnreadMessages', (tester) async {
    // arrange
    final unreadA = _buildMessage(id: 'm-unread-a', content: '안읽음 A');
    final unreadB = _buildMessage(id: 'm-unread-b', content: '안읽음 B');
    final alreadyRead = _buildMessage(
      id: 'm-read',
      content: '이미 읽음',
      readAt: DateTime.utc(2026, 7, 10, 5, 0, 0),
    );
    final fakeApi = _FakeMessagesApi();

    // act
    await tester.pumpWidget(
      buildTestable(
        const BroadcastInboxScreen(),
        overrides: [
          broadcastMessageListProvider.overrideWith((ref) => [unreadA, unreadB, alreadyRead]),
          messageApiProvider.overrideWithValue(fakeApi),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // assert
    expect(fakeApi.readCalledIds.toSet(), {'m-unread-a', 'm-unread-b'});
    expect(fakeApi.readCalledIds, isNot(contains('m-read')));
  });

  testWidgets('ShouldRenderLocalTimeLabelNotRawUtcString', (tester) async {
    // arrange
    final sentAt = DateTime.utc(2026, 7, 10, 3, 0, 0);
    // readAt을 채워 이 테스트에서는 읽음 처리 API가 호출되지 않도록 한다(표시 검증에 집중).
    final message = _buildMessage(id: 'm-1', content: '시각 표시 확인', sentAt: sentAt, readAt: sentAt);
    final fakeApi = _FakeMessagesApi();

    // act
    await tester.pumpWidget(
      buildTestable(
        const BroadcastInboxScreen(),
        overrides: [
          broadcastMessageListProvider.overrideWith((ref) => [message]),
          messageApiProvider.overrideWithValue(fakeApi),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // assert
    expect(find.byType(LocalTimeLabel), findsOneWidget);
    expect(find.text(sentAt.toIso8601String()), findsNothing);
  });
}
