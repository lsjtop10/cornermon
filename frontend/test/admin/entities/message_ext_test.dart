import 'package:cornermon/admin/entities/message_ext.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

MessageResponse _msg(
  String id,
  MessageResponseSenderRoleEnum role,
  String content, {
  DateTime? sentAt,
}) => MessageResponse(
  (b) => b
    ..id = id
    ..senderRole = role
    ..content = content
    ..sentAt = sentAt ?? DateTime(2026, 1, 1),
);

void main() {
  group('MessageX', () {
    test('ShouldIdentifySenderRoleWhenCheckingFromAdminOrTrack', () {
      // arrange
      final admin = _msg('1', MessageResponseSenderRoleEnum.ADMIN, 'hi');
      final track = _msg('2', MessageResponseSenderRoleEnum.TRACK, 'hi');

      // act / assert
      expect(admin.isFromAdmin, isTrue);
      expect(admin.isFromTrack, isFalse);
      expect(track.isFromAdmin, isFalse);
      expect(track.isFromTrack, isTrue);
    });

    test('ShouldTagQuickReplyWhenContentMatchesFixedPhrase', () {
      // arrange
      final quickReply = _msg('1', MessageResponseSenderRoleEnum.TRACK, '인원부족');
      final freeform = _msg('2', MessageResponseSenderRoleEnum.TRACK, '도와주세요');
      final adminSameText = _msg(
        '3',
        MessageResponseSenderRoleEnum.ADMIN,
        '인원부족',
      );

      // act / assert
      expect(quickReply.isQuickReplyTag, isTrue);
      expect(freeform.isQuickReplyTag, isFalse);
      expect(adminSameText.isQuickReplyTag, isFalse);
    });
  });

  group('MessageListX', () {
    test('ShouldReverseOrderWhenReadingNewestFirst', () {
      // arrange
      final oldest = _msg(
        '1',
        MessageResponseSenderRoleEnum.ADMIN,
        'a',
        sentAt: DateTime(2026, 1, 1),
      );
      final newest = _msg(
        '2',
        MessageResponseSenderRoleEnum.ADMIN,
        'b',
        sentAt: DateTime(2026, 1, 2),
      );

      // act
      final result = [oldest, newest].newestFirst;

      // assert
      expect(result.map((m) => m.id), ['2', '1']);
    });
  });
}
