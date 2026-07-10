// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add($TrackSummary.serializer)
      ..add(AdminSession.serializer)
      ..add(AdminSseSnapshot.serializer)
      ..add(AuditLog.serializer)
      ..add(AuditLogsGet200Response.serializer)
      ..add(AuthAdminLoginPost200Response.serializer)
      ..add(AuthAdminLoginPostRequest.serializer)
      ..add(AuthAdminRefreshPost200Response.serializer)
      ..add(AuthAdminSessionsGet200Response.serializer)
      ..add(AuthTrackLoginPost200Response.serializer)
      ..add(AuthTrackLoginPost200ResponseCorner.serializer)
      ..add(AuthTrackLoginPostRequest.serializer)
      ..add(Badge.serializer)
      ..add(BadgeStatus.serializer)
      ..add(BadgesBulkGeneratePost201Response.serializer)
      ..add(BadgesBulkGeneratePostRequest.serializer)
      ..add(BadgesGet200Response.serializer)
      ..add(BadgesIdRegisterPostRequest.serializer)
      ..add(BadgesScanRegisterPostRequest.serializer)
      ..add(BroadcastReceipt.serializer)
      ..add(Camp.serializer)
      ..add(CampReport.serializer)
      ..add(CampStatus.serializer)
      ..add(CampSummaryStats.serializer)
      ..add(CampSummaryStatsBottleneckRankingInner.serializer)
      ..add(CampsGet200Response.serializer)
      ..add(CampsIdPatchRequest.serializer)
      ..add(CampsPostRequest.serializer)
      ..add(Corner.serializer)
      ..add(CornerOperationalStatus.serializer)
      ..add(CornerProgress.serializer)
      ..add(CornerStats.serializer)
      ..add(CornerStatsTrackThroughputsInner.serializer)
      ..add(CornerStatsUnvisitedGroupsInner.serializer)
      ..add(CornersBulkUpdatePatch200Response.serializer)
      ..add(CornersBulkUpdatePatchRequest.serializer)
      ..add(CornersCornerIdTracksPostRequest.serializer)
      ..add(CornersGet200Response.serializer)
      ..add(CornersIdPatchRequest.serializer)
      ..add(CornersPostRequest.serializer)
      ..add(CornersPostRequestCornersInner.serializer)
      ..add(DeviceRegistration.serializer)
      ..add(DeviceRegistrationStatus.serializer)
      ..add(DeviceRegistrationsGet200Response.serializer)
      ..add(DeviceRegistrationsPost201Response.serializer)
      ..add(DeviceRegistrationsPostRequest.serializer)
      ..add(ErrorResponse.serializer)
      ..add(Group.serializer)
      ..add(GroupStats.serializer)
      ..add(GroupStatsCornerDurationsInner.serializer)
      ..add(GroupStatsUnvisitedCornersInner.serializer)
      ..add(GroupStatus.serializer)
      ..add(GroupsGet200Response.serializer)
      ..add(GroupsIdVisitsGet200Response.serializer)
      ..add(Message.serializer)
      ..add(MessageChannelType.serializer)
      ..add(MessageSenderRoleEnum.serializer)
      ..add(MessagesBroadcastGet200Response.serializer)
      ..add(MessagesBroadcastIdReceiptsGet200Response.serializer)
      ..add(MessagesBroadcastPostRequest.serializer)
      ..add(OperationalStats.serializer)
      ..add(OperationalStatsAdminActionCountsInner.serializer)
      ..add(OperationalStatsBroadcastReadRatesInner.serializer)
      ..add(OperationalStatsDirectMessageCountPerTrackInner.serializer)
      ..add(ReportsGeneratePostRequest.serializer)
      ..add(ReportsLiveSummaryGet200Response.serializer)
      ..add(ReportsLiveSummaryGet200ResponseCornersInner.serializer)
      ..add(SseEvent.serializer)
      ..add(SseEventEventEnum.serializer)
      ..add(TimelineStats.serializer)
      ..add(TimelineStatsInProgressCountsInner.serializer)
      ..add(Track.serializer)
      ..add(TrackOperationalStatus.serializer)
      ..add(TrackSseSnapshot.serializer)
      ..add(TrackStats.serializer)
      ..add(TrackStatus.serializer)
      ..add(TracksBulkDeletePostRequest.serializer)
      ..add(TracksGet200Response.serializer)
      ..add(TracksIdReplacePostRequest.serializer)
      ..add(TracksTrackIdVisitsStartPostRequest.serializer)
      ..add(TracksTrackIdVisitsStartPostRequestOneOf.serializer)
      ..add(TracksTrackIdVisitsStartPostRequestOneOf1.serializer)
      ..add(TracksTrackIdVisitsStartPostRequestOneOf1MethodEnum.serializer)
      ..add(VisitInputMethod.serializer)
      ..add(VisitStatus.serializer)
      ..add(VisitStatusPerCorner.serializer)
      ..add(VisitSummary.serializer)
      ..add(VisitsExceptionApprovePostRequest.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(AdminSession)]),
          () => ListBuilder<AdminSession>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(AuditLog)]),
          () => ListBuilder<AuditLog>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Badge)]),
          () => ListBuilder<Badge>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Badge)]),
          () => ListBuilder<Badge>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(BroadcastReceipt)]),
          () => ListBuilder<BroadcastReceipt>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Camp)]),
          () => ListBuilder<Camp>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(CampSummaryStatsBottleneckRankingInner)]),
          () => ListBuilder<CampSummaryStatsBottleneckRankingInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Corner)]),
          () => ListBuilder<Corner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Corner)]),
          () => ListBuilder<Corner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Group)]),
          () => ListBuilder<Group>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CornerProgress)]),
          () => ListBuilder<CornerProgress>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(CornerStats)]),
          () => ListBuilder<CornerStats>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TrackStats)]),
          () => ListBuilder<TrackStats>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GroupStats)]),
          () => ListBuilder<GroupStats>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(CornerStatsUnvisitedGroupsInner)]),
          () => ListBuilder<CornerStatsUnvisitedGroupsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(CornerStatsTrackThroughputsInner)]),
          () => ListBuilder<CornerStatsTrackThroughputsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(CornersPostRequestCornersInner)]),
          () => ListBuilder<CornersPostRequestCornersInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(DeviceRegistration)]),
          () => ListBuilder<DeviceRegistration>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Group)]),
          () => ListBuilder<Group>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GroupStatsCornerDurationsInner)]),
          () => ListBuilder<GroupStatsCornerDurationsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GroupStatsUnvisitedCornersInner)]),
          () => ListBuilder<GroupStatsUnvisitedCornersInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Message)]),
          () => ListBuilder<Message>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(OperationalStatsAdminActionCountsInner)]),
          () => ListBuilder<OperationalStatsAdminActionCountsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(OperationalStatsDirectMessageCountPerTrackInner)
          ]),
          () => ListBuilder<OperationalStatsDirectMessageCountPerTrackInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(OperationalStatsBroadcastReadRatesInner)]),
          () => ListBuilder<OperationalStatsBroadcastReadRatesInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(ReportsLiveSummaryGet200ResponseCornersInner)
          ]),
          () => ListBuilder<ReportsLiveSummaryGet200ResponseCornersInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(TimelineStatsInProgressCountsInner)]),
          () => ListBuilder<TimelineStatsInProgressCountsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(TimelineStatsInProgressCountsInner)]),
          () => ListBuilder<TimelineStatsInProgressCountsInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(Track)]),
          () => ListBuilder<Track>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TrackSummary)]),
          () => ListBuilder<TrackSummary>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(VisitSummary)]),
          () => ListBuilder<VisitSummary>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
