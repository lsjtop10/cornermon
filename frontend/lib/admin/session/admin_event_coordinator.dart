import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/api/providers/report_providers.dart';
import 'package:cornermon/shared/api/sse/admin_event_stream.dart';
import 'package:cornermon/shared/design_system/widgets/connection_banner.dart';
import 'selected_camp_provider.dart';

part 'admin_event_coordinator.g.dart';

/// `TrackEventCoordinator`(`facilitator/features/main_track/track_event_coordinator.dart`)와
/// 대칭되는 admin 쪽 디스패처. 연결상태 자체는 이미 `AdminConnection`
/// (`shared/api/sse/admin_event_stream.dart`)이 관리하므로 여기서 다시 만들지 않고,
/// 이 Notifier는 오직 "이번에 들어온 이벤트를 어떤 화면 provider의 invalidate로 매핑할지"와
/// "재연결 성사 시 전체 재조회"만 담당한다.
@riverpod
class AdminEventCoordinator extends _$AdminEventCoordinator {
  @override
  void build(CampId campId) {
    var wasConnected = false;

    ref.listen<AdminConnectionState>(
      adminConnectionProvider(campId),
      (previous, next) {
        if (!wasConnected && next == AdminConnectionState.connected) {
          _fullRefresh(campId);
        }
        wasConnected = next == AdminConnectionState.connected;
      },
      fireImmediately: true,
    );

    ref.listen(adminEventsProvider(campId), (previous, next) {
      next.whenData((event) => _handle(campId, event));
    });
  }

  void _handle(CampId campId, SseEvent event) {
    switch (event.event) {
      case SseEventEventEnum.tracksUpdated:
        ref.invalidate(trackListProvider(campId));
        ref.invalidate(cornerListProvider(campId));
        ref.invalidate(liveSummaryProvider(campId));
        break;
      case SseEventEventEnum.trackUpdated:
        // 코너의 busy/idle 배지(A1 대시보드, cornerListProvider)는 개별 트랙 하나의 상태
        // 전환만으로도 바뀔 수 있다 — corners_updated를 별도로 기다리지 않고 여기서도
        // 갱신한다(track_deleted/trackReplaced와 동일한 이유).
        ref.invalidate(trackListProvider(campId));
        ref.invalidate(cornerListProvider(campId));
        ref.invalidate(cornerDetailProvider);
        ref.invalidate(liveSummaryProvider(campId));
        break;
      case SseEventEventEnum.cornersUpdated:
        ref.invalidate(cornerListProvider(campId));
        ref.invalidate(cornerDetailProvider);
        ref.invalidate(liveSummaryProvider(campId));
        break;
      case SseEventEventEnum.groupsUpdated:
        ref.invalidate(groupListProvider(campId));
        ref.invalidate(groupDetailProvider);
        ref.invalidate(groupVisitsProvider);
        break;
      case SseEventEventEnum.campUpdated:
        ref.invalidate(campDetailProvider(campId));
        ref.invalidate(selectedCampProvider);
        break;
      case SseEventEventEnum.messagesChanged:
        ref.invalidate(broadcastMessageListProvider(campId));
        ref.invalidate(trackMessageListProvider);
        break;
      case SseEventEventEnum.trackDeleted:
        ref.invalidate(trackListProvider(campId));
        ref.invalidate(cornerListProvider(campId));
        ref.invalidate(cornerDetailProvider);
        break;
      case SseEventEventEnum.trackReplaced:
        ref.invalidate(trackListProvider(campId));
        ref.invalidate(cornerListProvider(campId));
        ref.invalidate(cornerDetailProvider);
        break;
      case SseEventEventEnum.sessionRevoked:
        ref.invalidate(adminSessionListProvider);
        break;
      case SseEventEventEnum.campEnded:
        ref.invalidate(campDetailProvider(campId));
        ref.invalidate(selectedCampProvider);
        break;
      case SseEventEventEnum.deviceRegistrationUpdated:
        ref.invalidate(deviceRegistrationListProvider(campId));
        break;
      case SseEventEventEnum.lockoutAlert:
        ref.invalidate(lockedDeviceListProvider(campId));
        break;
      default:
        break;
    }
  }

  /// 재연결(또는 최초 연결) 성사 시 1회 호출 — 개별 이벤트 매핑을 신뢰하지 않고
  /// 이 캠프에서 관리자가 볼 수 있는 모든 목록을 무조건 다시 부른다(best-effort 유실 보완).
  void _fullRefresh(CampId campId) {
    ref.invalidate(trackListProvider(campId));
    ref.invalidate(cornerListProvider(campId));
    ref.invalidate(cornerDetailProvider);
    ref.invalidate(liveSummaryProvider(campId));
    ref.invalidate(groupListProvider(campId));
    ref.invalidate(groupDetailProvider);
    ref.invalidate(groupVisitsProvider);
    ref.invalidate(campDetailProvider(campId));
    ref.invalidate(selectedCampProvider);
    ref.invalidate(broadcastMessageListProvider(campId));
    ref.invalidate(trackMessageListProvider);
    ref.invalidate(adminSessionListProvider);
    ref.invalidate(deviceRegistrationListProvider(campId));
    ref.invalidate(lockedDeviceListProvider(campId));
    ref.invalidate(activeSessionListProvider(campId));
  }
}

/// `ConnectionBanner`(B2 헤더 패턴과 대칭, `shared/design_system/widgets/connection_banner.dart`)에
/// 매핑할 상태. 캠프 미선택 시 SSE 자체가 필요 없는 정상 상태이므로 `hidden`으로 간주한다
/// (배너는 "끊겼을 때만" 뜬다).
@riverpod
ConnectionBannerState adminConnectionBannerState(Ref ref) {
  final campId = ref.watch(selectedCampIdProvider);
  if (campId == null) return ConnectionBannerState.hidden;

  // 디스패처를 살려 둬서 구독이 유지되도록 한다(캠프 선택 중엔 정확히 하나만 구독).
  ref.watch(adminEventCoordinatorProvider(campId));

  return switch (ref.watch(adminConnectionProvider(campId))) {
    AdminConnectionState.connected => ConnectionBannerState.hidden,
    AdminConnectionState.reconnecting => ConnectionBannerState.reconnecting,
    AdminConnectionState.disconnected => ConnectionBannerState.disconnected,
  };
}
