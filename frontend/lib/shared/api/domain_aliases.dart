// Swagger 2.0 정의(`api/swagger.yaml`)는 모델명에 Request/Response 접미사를 명시적으로 붙이고
// 상태 enum을 각 모델에 중첩시킨다(예: `CampResponseStatusEnum`, 공유 top-level `CampStatus` 없음).
// 이 파일은 도메인 유비쿼터스 언어(`CLAUDE.md` 표)에 맞춘 짧은 이름으로 그 생성 타입들을 가리키는
// typedef만 모아둔다 — 새 타입을 정의하지 않으므로 여기서 파생 로직/메서드를 추가하지 않는다.
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

typedef Camp = CampResponse;
typedef CampStatus = CampResponseStatusEnum;
typedef Track = TrackResponse;
typedef TrackStatus = TrackResponseStatusEnum;
typedef TrackOperationalStatus = TrackResponseOperationalStatusEnum;
typedef Corner = CornerResponse;
typedef CornerOperationalStatus = CornerResponseStatusEnum;
typedef CornerProgress = CornerProgressResponse;
typedef VisitStatusPerCorner = CornerProgressResponseStatusEnum;
typedef Group = GroupResponse;
typedef GroupStatus = GroupResponseStatusEnum;
typedef Badge = BadgeResponse;
typedef BadgeStatus = BadgeResponseStatusEnum;
typedef Message = MessageResponse;
typedef MessageChannelType = MessageResponseChannelTypeEnum;
typedef MessageSenderRole = MessageResponseSenderRoleEnum;
typedef MessageSenderRoleEnum = MessageResponseSenderRoleEnum;
typedef BroadcastReceipt = BroadcastReceiptResponse;
typedef DeviceRegistration = DeviceRegistrationResponse;
typedef DeviceRegistrationStatus = DeviceRegistrationResponseStatusEnum;
typedef DeviceRegistrationRequestBody = DeviceRegistrationRequest;
typedef DeviceRegistrationCreated = DeviceRegistrationCreatedResponse;
typedef DeviceRegistrationCreatedStatus = DeviceRegistrationCreatedResponseStatusEnum;
typedef AdminSession = AdminSessionResponse;
typedef FacilitatorSession = FacilitatorSessionResponse;
typedef AuditLog = AuditLogResponse;
typedef AuditLogPage = AuditLogPageResponse;
typedef CampReport = CampReportResponse;
typedef CampSummaryStats = CampSummaryStatsResponse;
typedef CornerStats = CornerStatsResponse;
typedef GroupStats = GroupStatsResponse;
typedef TrackStats = TrackStatsResponse;
typedef TrackSummary = TrackSummaryResponse;
typedef CornerMetric = CornerMetricResponse;
typedef UnvisitedGroup = UnvisitedGroupResponse;
typedef VisitSummary = VisitSummaryResponse;
typedef VisitStatus = VisitSummaryResponseStatusEnum;
typedef TrackPin = TrackPinResponse;
typedef TrackLogin = TrackLoginResponse;
typedef AuthTrackLoginPost200Response = TrackLoginResponse;
typedef AuthTrackLoginPost200ResponseBuilder = TrackLoginResponseBuilder;
typedef AuthTrackLoginPost200ResponseCorner = CornerResponse;
typedef AuthTrackLoginPostRequest = TrackLoginRequest;
typedef AuthTrackLoginPostRequestBuilder = TrackLoginRequestBuilder;
typedef DeviceRegistrationsPostRequest = DeviceRegistrationRequest;
typedef DeviceRegistrationsPostRequestBuilder = DeviceRegistrationRequestBuilder;
typedef SseEvent = SSENotification;
typedef SseEventEventEnum = SSENotificationEventEnum;
typedef SseScopeKind = SSEScopeKindEnum;
