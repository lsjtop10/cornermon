import '../../shared/api/domain_aliases.dart' as api;

/// 트랙 쪽에서 오는 정형 빠른 답장 문구. 서버 계약(MessageResponse)에는
/// "빠른 답장 여부"를 나타내는 별도 필드가 없다 — content 문자열이 이 셋과
/// 정확히 일치하는지로만 판별하는 단순화된 방식이다.
/// facilitator/features/track_direct/track_direct_screen.dart의 빠른 버튼 3개
/// 고정 문자열과 1:1로 동기화되어야 한다.
const kQuickReplyTags = {'인원부족', '자재부족', '긴급도움요청'};

extension MessageX on api.Message {
  bool get isFromAdmin => senderRole == api.MessageSenderRoleEnum.ADMIN;
  bool get isFromTrack => senderRole == api.MessageSenderRoleEnum.TRACK;

  /// 트랙발 메시지이면서 content가 빠른 답장 고정 문구와 정확히 일치하면 true.
  bool get isQuickReplyTag => isFromTrack && kQuickReplyTags.contains(content);
}

extension MessageListX on List<api.Message> {
  /// sentAt 오름차순 응답을 최신순으로 뒤집는다(A10 발송 이력용).
  List<api.Message> get newestFirst => reversed.toList();
}
