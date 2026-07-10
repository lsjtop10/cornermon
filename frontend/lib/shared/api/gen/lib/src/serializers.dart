//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:cornermon_api_gen/src/date_serializer.dart';
import 'package:cornermon_api_gen/src/model/date.dart';

import 'package:cornermon_api_gen/src/model/admin_session.dart';
import 'package:cornermon_api_gen/src/model/audit_log.dart';
import 'package:cornermon_api_gen/src/model/audit_logs_get200_response.dart';
import 'package:cornermon_api_gen/src/model/auth_admin_login_post200_response.dart';
import 'package:cornermon_api_gen/src/model/auth_admin_login_post_request.dart';
import 'package:cornermon_api_gen/src/model/auth_admin_refresh_post200_response.dart';
import 'package:cornermon_api_gen/src/model/auth_admin_sessions_get200_response.dart';
import 'package:cornermon_api_gen/src/model/auth_track_login_post200_response.dart';
import 'package:cornermon_api_gen/src/model/auth_track_login_post200_response_corner.dart';
import 'package:cornermon_api_gen/src/model/auth_track_login_post_request.dart';
import 'package:cornermon_api_gen/src/model/badge.dart';
import 'package:cornermon_api_gen/src/model/badge_status.dart';
import 'package:cornermon_api_gen/src/model/badges_bulk_generate_post201_response.dart';
import 'package:cornermon_api_gen/src/model/badges_bulk_generate_post_request.dart';
import 'package:cornermon_api_gen/src/model/badges_get200_response.dart';
import 'package:cornermon_api_gen/src/model/badges_id_register_post_request.dart';
import 'package:cornermon_api_gen/src/model/badges_scan_register_post_request.dart';
import 'package:cornermon_api_gen/src/model/broadcast_receipt.dart';
import 'package:cornermon_api_gen/src/model/camp.dart';
import 'package:cornermon_api_gen/src/model/camp_report.dart';
import 'package:cornermon_api_gen/src/model/camp_status.dart';
import 'package:cornermon_api_gen/src/model/camp_summary_stats.dart';
import 'package:cornermon_api_gen/src/model/camp_summary_stats_bottleneck_ranking_inner.dart';
import 'package:cornermon_api_gen/src/model/camps_get200_response.dart';
import 'package:cornermon_api_gen/src/model/camps_id_patch_request.dart';
import 'package:cornermon_api_gen/src/model/camps_post_request.dart';
import 'package:cornermon_api_gen/src/model/corner.dart';
import 'package:cornermon_api_gen/src/model/corner_operational_status.dart';
import 'package:cornermon_api_gen/src/model/corner_progress.dart';
import 'package:cornermon_api_gen/src/model/corner_stats.dart';
import 'package:cornermon_api_gen/src/model/corner_stats_track_throughputs_inner.dart';
import 'package:cornermon_api_gen/src/model/corner_stats_unvisited_groups_inner.dart';
import 'package:cornermon_api_gen/src/model/corners_bulk_update_patch200_response.dart';
import 'package:cornermon_api_gen/src/model/corners_bulk_update_patch_request.dart';
import 'package:cornermon_api_gen/src/model/corners_corner_id_tracks_post_request.dart';
import 'package:cornermon_api_gen/src/model/corners_get200_response.dart';
import 'package:cornermon_api_gen/src/model/corners_id_patch_request.dart';
import 'package:cornermon_api_gen/src/model/corners_post_request.dart';
import 'package:cornermon_api_gen/src/model/corners_post_request_corners_inner.dart';
import 'package:cornermon_api_gen/src/model/device_registration.dart';
import 'package:cornermon_api_gen/src/model/device_registration_status.dart';
import 'package:cornermon_api_gen/src/model/device_registrations_get200_response.dart';
import 'package:cornermon_api_gen/src/model/device_registrations_post201_response.dart';
import 'package:cornermon_api_gen/src/model/device_registrations_post_request.dart';
import 'package:cornermon_api_gen/src/model/error_response.dart';
import 'package:cornermon_api_gen/src/model/group.dart';
import 'package:cornermon_api_gen/src/model/group_stats.dart';
import 'package:cornermon_api_gen/src/model/group_stats_corner_durations_inner.dart';
import 'package:cornermon_api_gen/src/model/group_stats_unvisited_corners_inner.dart';
import 'package:cornermon_api_gen/src/model/group_status.dart';
import 'package:cornermon_api_gen/src/model/groups_get200_response.dart';
import 'package:cornermon_api_gen/src/model/groups_id_visits_get200_response.dart';
import 'package:cornermon_api_gen/src/model/message.dart';
import 'package:cornermon_api_gen/src/model/message_channel_type.dart';
import 'package:cornermon_api_gen/src/model/messages_broadcast_get200_response.dart';
import 'package:cornermon_api_gen/src/model/messages_broadcast_id_receipts_get200_response.dart';
import 'package:cornermon_api_gen/src/model/messages_broadcast_post_request.dart';
import 'package:cornermon_api_gen/src/model/operational_stats.dart';
import 'package:cornermon_api_gen/src/model/operational_stats_admin_action_counts_inner.dart';
import 'package:cornermon_api_gen/src/model/operational_stats_broadcast_read_rates_inner.dart';
import 'package:cornermon_api_gen/src/model/operational_stats_direct_message_count_per_track_inner.dart';
import 'package:cornermon_api_gen/src/model/reports_generate_post_request.dart';
import 'package:cornermon_api_gen/src/model/reports_live_summary_get200_response.dart';
import 'package:cornermon_api_gen/src/model/reports_live_summary_get200_response_corners_inner.dart';
import 'package:cornermon_api_gen/src/model/sse_event.dart';
import 'package:cornermon_api_gen/src/model/sse_notification_data.dart';
import 'package:cornermon_api_gen/src/model/timeline_stats.dart';
import 'package:cornermon_api_gen/src/model/timeline_stats_in_progress_counts_inner.dart';
import 'package:cornermon_api_gen/src/model/track.dart';
import 'package:cornermon_api_gen/src/model/track_operational_status.dart';
import 'package:cornermon_api_gen/src/model/track_stats.dart';
import 'package:cornermon_api_gen/src/model/track_status.dart';
import 'package:cornermon_api_gen/src/model/track_summary.dart';
import 'package:cornermon_api_gen/src/model/tracks_bulk_delete_post_request.dart';
import 'package:cornermon_api_gen/src/model/tracks_get200_response.dart';
import 'package:cornermon_api_gen/src/model/tracks_id_replace_post_request.dart';
import 'package:cornermon_api_gen/src/model/tracks_track_id_visits_start_post_request.dart';
import 'package:cornermon_api_gen/src/model/tracks_track_id_visits_start_post_request_one_of.dart';
import 'package:cornermon_api_gen/src/model/tracks_track_id_visits_start_post_request_one_of1.dart';
import 'package:cornermon_api_gen/src/model/visit_input_method.dart';
import 'package:cornermon_api_gen/src/model/visit_status.dart';
import 'package:cornermon_api_gen/src/model/visit_status_per_corner.dart';
import 'package:cornermon_api_gen/src/model/visit_summary.dart';
import 'package:cornermon_api_gen/src/model/visits_exception_approve_post_request.dart';

part 'serializers.g.dart';

@SerializersFor([
  AdminSession,
  AuditLog,
  AuditLogsGet200Response,
  AuthAdminLoginPost200Response,
  AuthAdminLoginPostRequest,
  AuthAdminRefreshPost200Response,
  AuthAdminSessionsGet200Response,
  AuthTrackLoginPost200Response,
  AuthTrackLoginPost200ResponseCorner,
  AuthTrackLoginPostRequest,
  Badge,
  BadgeStatus,
  BadgesBulkGeneratePost201Response,
  BadgesBulkGeneratePostRequest,
  BadgesGet200Response,
  BadgesIdRegisterPostRequest,
  BadgesScanRegisterPostRequest,
  BroadcastReceipt,
  Camp,
  CampReport,
  CampStatus,
  CampSummaryStats,
  CampSummaryStatsBottleneckRankingInner,
  CampsGet200Response,
  CampsIdPatchRequest,
  CampsPostRequest,
  Corner,
  CornerOperationalStatus,
  CornerProgress,
  CornerStats,
  CornerStatsTrackThroughputsInner,
  CornerStatsUnvisitedGroupsInner,
  CornersBulkUpdatePatch200Response,
  CornersBulkUpdatePatchRequest,
  CornersCornerIdTracksPostRequest,
  CornersGet200Response,
  CornersIdPatchRequest,
  CornersPostRequest,
  CornersPostRequestCornersInner,
  DeviceRegistration,
  DeviceRegistrationStatus,
  DeviceRegistrationsGet200Response,
  DeviceRegistrationsPost201Response,
  DeviceRegistrationsPostRequest,
  ErrorResponse,
  Group,
  GroupStats,
  GroupStatsCornerDurationsInner,
  GroupStatsUnvisitedCornersInner,
  GroupStatus,
  GroupsGet200Response,
  GroupsIdVisitsGet200Response,
  Message,
  MessageChannelType,
  MessagesBroadcastGet200Response,
  MessagesBroadcastIdReceiptsGet200Response,
  MessagesBroadcastPostRequest,
  OperationalStats,
  OperationalStatsAdminActionCountsInner,
  OperationalStatsBroadcastReadRatesInner,
  OperationalStatsDirectMessageCountPerTrackInner,
  ReportsGeneratePostRequest,
  ReportsLiveSummaryGet200Response,
  ReportsLiveSummaryGet200ResponseCornersInner,
  SseEvent,
  SseNotificationData,
  TimelineStats,
  TimelineStatsInProgressCountsInner,
  Track,
  TrackOperationalStatus,
  TrackStats,
  TrackStatus,
  TrackSummary,$TrackSummary,
  TracksBulkDeletePostRequest,
  TracksGet200Response,
  TracksIdReplacePostRequest,
  TracksTrackIdVisitsStartPostRequest,
  TracksTrackIdVisitsStartPostRequestOneOf,
  TracksTrackIdVisitsStartPostRequestOneOf1,
  VisitInputMethod,
  VisitStatus,
  VisitStatusPerCorner,
  VisitSummary,
  VisitsExceptionApprovePostRequest,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(TrackSummary.serializer)
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
