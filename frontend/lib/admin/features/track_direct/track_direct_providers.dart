import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/admin/entities/message_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';

part 'track_direct_providers.g.dart';

@riverpod
class SelectedDirectTrackId extends _$SelectedDirectTrackId {
  @override
  TrackId? build() => null;

  void select(TrackId id) => state = id;
}

/// A11 좌측 트랙 목록 한 행에 필요한 파생 데이터.
class TrackDirectSummary {
  const TrackDirectSummary({
    required this.track,
    required this.cornerName,
    required this.lastMessage,
    required this.unreadCount,
  });

  final api.Track track;
  final String cornerName;
  final api.Message? lastMessage;
  final int unreadCount;
}

/// 캠프의 전체 트랙(ACTIVE + DELETED) × 트랙별 메시지 목록을 조합해
/// 좌측 목록에 필요한 미리보기·안읽음 카운트를 만든다.
/// **주의(N+1 호출)**: 트랙별 GET을 트랙 수만큼 병렬 호출한다 — 캠프당 트랙 10~20개
/// 가정에서는 허용, 트랙이 훨씬 많아지면 서버에 요약 엔드포인트를 신설해야 한다(범위 밖).
@riverpod
Future<List<TrackDirectSummary>> trackDirectSummaries(
  Ref ref,
  CampId campId,
) async {
  final tracks = await ref.watch(trackListProvider(campId).future);
  final corners = await ref.watch(cornerListProvider(campId).future);
  final cornerNameOf = {for (final c in corners) c.id: c.name ?? '이름 없는 코너'};

  final summaries = await Future.wait(
    tracks.map((t) async {
      // background: true — 좌측 목록 미리보기 조회일 뿐 스레드를 "열람"한 게 아니므로
      // 읽음 처리되면 안 된다.
      final messages = await ref.watch(
        trackMessageListProvider(
          TrackId(t.id ?? ''),
          background: true,
        ).future,
      );
      final unread = messages.where((m) => m.isFromTrack && m.isRead != true).length;
      return TrackDirectSummary(
        track: t,
        cornerName: cornerNameOf[t.cornerId] ?? '삭제된 코너',
        lastMessage: messages.isEmpty ? null : messages.last,
        unreadCount: unread,
      );
    }),
  );

  summaries.sort((a, b) {
    final at = a.lastMessage?.sentAt;
    final bt = b.lastMessage?.sentAt;
    if (at == null && bt == null) {
      return (a.track.trackNo ?? 0).compareTo(b.track.trackNo ?? 0);
    }
    if (at == null) return 1;
    if (bt == null) return -1;
    return bt.compareTo(at);
  });
  return summaries;
}
