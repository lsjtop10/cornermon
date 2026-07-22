import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/api/sse/track_event_stream.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/facilitator/session/facilitator_broadcast_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';

part 'track_event_coordinator.g.dart';

/// 인증된 트랙 세션의 SSE 수신·재조회 경계를 한 곳에서 관리한다.
///
/// 메시지·공지, 방문 상태, 세션 종료는 서로 다른 도메인 관심사지만, 현재는 모두 같은 트랙
/// 세션의 단일 SSE 연결에서 도착하고 각 provider를 재조회시키는 얇은 어댑터다. 따라서 지금은
/// 연결·재연결·세션 수명을 한 코디네이터에 둔다. 각 이벤트에 독자적인 정책 또는 화면별 구독
/// 수명이 생길 때에만 메시지/방문/세션 코디네이터로 분리한다.
///
/// 이벤트 분기는 위젯이 아니라 이 Notifier에 둔다. 위젯 build() 안에서 스트림 값에 반응해
/// 동기적으로 ref.invalidate를 호출하면 빌드 사이클 도중 provider를 바꾸다 예외가 날 수 있다.
/// 화면은 이 결과만 watch하고, 앱 루트가 인증 세션 동안의 생명주기를 소유한다.
@riverpod
class TrackEventCoordinator extends _$TrackEventCoordinator {
  @override
  void build(TrackId trackId) {
    ref.listen(trackEventsProvider(trackId), (previous, next) {
      next.whenData((event) => _handle(trackId, event));
    });
  }

  void _handle(TrackId trackId, SseEvent event) {
    final scope = event.scope;
    final isThisTrack =
        scope?.kind == SseScopeKind.track && scope?.trackId == trackId.value;
    switch (event.event) {
      case SseEventEventEnum.trackUpdated:
        // 계약상(api/swagger.yaml /events/track/{trackId})이 스트림엔 이미 "자기 트랙"
        // 알림만 오지만, 공짜로 넣을 수 있는 방어 코드라 scope를 한 번 더 확인한다.
        if (isThisTrack) {
          ref.invalidate(currentVisitProvider(trackId));
        }
        break;
      case SseEventEventEnum.campUpdated:
        // 캠프 범위 변경은 상태 스냅샷이 없는 일반 알림이다. 현재 방문을 REST로
        // 재조회하고, 종료로 인해 트랙 세션이 401이면 AuthInterceptor가 기기 상태
        // 조회로 최종 원인을 판정한다.
        if (scope?.kind == SseScopeKind.camp) {
          ref.invalidate(currentVisitProvider(trackId));
        }
        break;
      case SseEventEventEnum.cornersUpdated:
        // 관리자가 코너 목표시간 등을 바꾸면 camp 스코프로 브로드캐스트된다(백엔드가 캠프 내
        // 모든 트랙 구독자에게도 전달, backend/internal/infrastructure/sse/broadcaster.go).
        // 로그인 스냅샷(session.corner)이 최신이 아닐 수 있으므로 TrackAuth 조회로 갱신한다.
        if (scope?.kind == SseScopeKind.camp) {
          ref.invalidate(trackCornerProvider(trackId));
        }
        break;
      case SseEventEventEnum.messagesChanged:
        if (scope?.kind == SseScopeKind.camp) {
          final campId = facilitatorBroadcastCampId(
            ref.read(trackSessionProvider),
          );
          if (campId != null) {
            // facade provider만 invalidate하면 내부 family의 HTTP 결과는 캐시된 채다.
            // 실제 목록 provider를 무효화해야 새 공지를 GET으로 다시 가져온다.
            ref.invalidate(broadcastMessageListProvider(campId));
          }
        } else if (isThisTrack) {
          ref.invalidate(trackMessageListProvider(trackId, background: true));
          ref.invalidate(unreadDirectMessageCountProvider(trackId));
        }
        break;
      case SseEventEventEnum.trackDeleted:
        // 트랙 삭제·교체(§00 §0-c 결정, 재PIN 없는 자동전환 계약 미비) 모두 이 분기로 흡수한다.
        ref
            .read(trackSessionProvider.notifier)
            .handleTermination(TrackSessionTerminationReason.trackDeleted);
        break;
      case SseEventEventEnum.sessionRevoked:
        ref
            .read(trackSessionProvider.notifier)
            .handleTermination(TrackSessionTerminationReason.forceLogout);
        break;
      case SseEventEventEnum.campEnded:
        unawaited(_handleCampEnded());
        break;
      default:
        break; // groups_updated/lockout_alert 등 관리자 전용 알림은 진행자 화면과 무관
    }
  }

  Future<void> _handleCampEnded() async {
    await ref.read(deviceTrustProvider.notifier).clearRegistration();
    ref
        .read(trackSessionProvider.notifier)
        .handleTermination(TrackSessionTerminationReason.campEnded);
  }
}
