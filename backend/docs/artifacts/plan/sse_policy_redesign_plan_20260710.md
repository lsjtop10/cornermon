# SSE 전송 정책 변경에 따른 포트 및 유즈케이스 재설계 계획

## 1. 개요 및 변경 사유

기존 SSE(Server-Sent Events) 전송 정책은 서버 내부 상태 변경 시 캠프의 전체 스냅샷 데이터를 실시간으로 푸시하는 방식이었습니다. 
하지만 새로운 정책(하이브리드 알림+풀 모델, §technical-design.md 2.3)에 따라, **SSE는 데이터를 직접 실시간으로 나르지 않고 얇은 "변경 알림(Notification)"만 전송**하게 되었습니다.

클라이언트는 알림 `{event, data: {scope}}`을 받으면 각 스코프에 매핑된 REST 엔드포인트를 호출하여 최신 데이터를 풀(Fetch)해갑니다.
이에 따라 백엔드의 `Broadcaster` 포트 인터페이스를 개편하고, 기기 신뢰 및 로그인 실패(락아웃) 알림을 포함하여 각 비즈니스 유즈케이스에서 적절한 알림 이벤트를 전송하도록 재설계합니다.

---

## 2. 유즈케이스 정의 및 우선순위

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| :--- | :--- | :--- | :--- |
| **P0** | **UC-SSE-1: Broadcaster 포트 개편** | 얇은 변경 알림을 보낼 수 있도록 `Broadcast(ctx, campID, event, scope)` 구조로 수정 | **프로덕션 핵심 포트** |
| **P0** | **UC-SSE-2: 도메인 엔티티 수정** | 기기 조치 시 캠프 ID 식별을 위해 `domain.DeviceRegistration`에 `CampID` 추가 | **프로덕션 도메인 수정** |
| **P0** | **UC-SSE-3: 캠프 유즈케이스 수정** | 캠프 활성화/종료 시 `camp_updated`, `camp_ended` 알림 발송 | **프로덕션 핵심 로직** |
| **P0** | **UC-SSE-4: 트랙 유즈케이스 수정** | 트랙 생성/삭제/교체 및 PIN 변경 시 `tracks_updated`, `track_deleted`, `session_revoked` 알림 발송 | **프로덕션 핵심 로직** |
| **P0** | **UC-SSE-5: 방문 유즈케이스 수정** | 방문 시작 및 완료 시 `corners_updated`, `groups_updated`, `tracks_updated`, `track_updated` 알림 발송 | **프로덕션 핵심 로직** |
| **P0** | **UC-SSE-6: 메시지 유즈케이스 수정** | 공지 발송 및 다이렉트 메시지 발송 시 `messages_changed` 알림 발송 | **프로덕션 핵심 로직** |
| **P1** | **UC-SSE-7: 기기 승인 및 잠금 알림 추가** | 기기 요청/승인/거부/회수 시 및 로그인 실패 임계치 도달(락아웃) 시 `device_registration_updated`, `lockout_alert` 알림 발송 | **프로덕션 보조 로직** |

---

## 3. 객체 및 인터페이스 정의

### 3.1 `Broadcaster` 포트 개편 (internal/usecase/port.go)

기존 `BroadcastSnapshot`을 제거하고, OpenAPI 스펙의 이벤트 명세를 반영한 `Broadcast` 메서드로 변경합니다.

```go
type NotificationEvent string

const (
	EventTracksUpdated            NotificationEvent = "tracks_updated"
	EventTrackUpdated             NotificationEvent = "track_updated"
	EventCornersUpdated           NotificationEvent = "corners_updated"
	EventGroupsUpdated            NotificationEvent = "groups_updated"
	EventCampUpdated              NotificationEvent = "camp_updated"
	EventMessagesChanged          NotificationEvent = "messages_changed"
	EventTrackDeleted             NotificationEvent = "track_deleted"
	EventSessionRevoked           NotificationEvent = "session_revoked"
	EventCampEnded                NotificationEvent = "camp_ended"
	EventDeviceRegistrationUpdated NotificationEvent = "device_registration_updated"
	EventLockoutAlert             NotificationEvent = "lockout_alert"
)

type Broadcaster interface {
	Broadcast(ctx context.Context, campID domain.CampID, event NotificationEvent, scope string) error
}
```

### 3.2 도메인 엔티티 수정 (internal/domain/device_registration.go)

기기 상태 업데이트 및 로그인 실패로 인한 락아웃 알림 시, 어느 캠프에 속한 이벤트인지 전달하기 위해 `CampID`를 엔티티에 추가합니다.

```go
type DeviceRegistration struct {
	ID                DeviceRegistrationID
	CampID            CampID // 추가
	DeviceName        string
	Status            DeviceRegistrationStatus
	TokenHash         string
	FailedPinAttempts int
	LockedUntil       Optional[time.Time]
	ApprovedAt        Optional[time.Time]
}
```

---

## 4. 유즈케이스별 알림 발송 설계 (Service Layer)

### 4.1 `CampService` (internal/usecase/camp.go)
- **ActivateCamp** (UC-18): 
  - `broadcaster.Broadcast(ctx, campID, EventCampUpdated, "camp")`
- **EndCamp** (UC-20): 
  - `broadcaster.Broadcast(ctx, campID, EventCampUpdated, "camp")`
  - `broadcaster.Broadcast(ctx, campID, EventCampEnded, "camp")`

### 4.2 `TrackService` (internal/usecase/track.go)
- **CreateTrack** (UC-4): 
  - `broadcaster.Broadcast(ctx, campID, EventTracksUpdated, "camp")`
- **DeleteTrack** (UC-5): 
  - `broadcaster.Broadcast(ctx, cornerCampID, EventTracksUpdated, "camp")`
  - `broadcaster.Broadcast(ctx, cornerCampID, EventTrackDeleted, "track:"+string(trackID))`
- **ReplaceTrack** (UC-6): 
  - `broadcaster.Broadcast(ctx, newCorner.CampID, EventTracksUpdated, "camp")`
  - `broadcaster.Broadcast(ctx, newCorner.CampID, EventTrackDeleted, "track:"+string(oldTrackID))`
- **RegeneratePIN** (UC-7): 
  - `broadcaster.Broadcast(ctx, cornerCampID, EventTracksUpdated, "camp")`
  - `broadcaster.Broadcast(ctx, cornerCampID, EventSessionRevoked, "track:"+string(trackID))`

### 4.3 `VisitService` (internal/usecase/visit.go)
- **StartVisitByQR** (UC-1) / **StartVisitManual** (UC-2) / **CompleteVisit** (UC-3):
  - `broadcaster.Broadcast(ctx, groupCampID, EventCornersUpdated, "camp")`
  - `broadcaster.Broadcast(ctx, groupCampID, EventGroupsUpdated, "camp")`
  - `broadcaster.Broadcast(ctx, groupCampID, EventTracksUpdated, "camp")`
  - `broadcaster.Broadcast(ctx, groupCampID, EventTrackUpdated, "track:"+string(track.ID))`

### 4.4 `MessageService` (internal/usecase/message.go)
- **SendBroadcast** (UC-21):
  - `broadcaster.Broadcast(ctx, campID, EventMessagesChanged, "broadcast")`
- **SendDirect** (UC-22):
  - `broadcaster.Broadcast(ctx, campID, EventMessagesChanged, "track:"+string(trackID))` (기존 미완성 주석 제거 후 로직 반영)

### 4.5 `DeviceTrustService` (internal/usecase/device_trust.go)
- 의존성에 `broadcaster Broadcaster` 추가
- **RequestRegistration** (UC-8) / **ApproveDevice** / **RejectDevice** / **RevokeDevice** (UC-14/15):
  - `broadcaster.Broadcast(ctx, device.CampID, EventDeviceRegistrationUpdated, "camp")`
- **ResetPinFailures** (UC-16):
  - `broadcaster.Broadcast(ctx, device.CampID, EventDeviceRegistrationUpdated, "camp")`

### 4.6 `FacilitatorAuthService` (internal/usecase/auth_facilitator.go)
- 의존성에 `broadcaster Broadcaster` 추가
- **Login** (UC-9) 시 PIN 5회 이상 실패하여 락아웃 조건(`needsAdminAlert`가 true)이 될 때:
  - `broadcaster.Broadcast(ctx, device.CampID, EventLockoutAlert, "device:"+string(device.ID))`

---

## 5. 구현 단계 (Implementation Phases)

### Phase A: 도메인 및 포트 계층 수정 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| A-1 | `DeviceRegistration` 도메인에 `CampID` 추가 | `backend/internal/domain/device_registration.go` |
| A-2 | `Broadcaster` 인터페이스 및 이벤트 상수 정의 | `backend/internal/usecase/port.go` |

### Phase B: 유즈케이스 서비스 계층 구현 (예상 소요: 2시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| B-1 | `CampService` 내 알림 발송 적용 | `backend/internal/usecase/camp.go` |
| B-2 | `TrackService` 내 알림 발송 적용 | `backend/internal/usecase/track.go` |
| B-3 | `VisitService` 내 알림 발송 적용 | `backend/internal/usecase/visit.go` |
| B-4 | `MessageService` 내 알림 발송 적용 | `backend/internal/usecase/message.go` |
| B-5 | `DeviceTrustService` 생성자/필드에 Broadcaster 주입 및 알림 적용 | `backend/internal/usecase/device_trust.go` |
| B-6 | `FacilitatorAuthService` 생성자/필드에 Broadcaster 주입 및 락아웃 알림 적용 | `backend/internal/usecase/auth_facilitator.go` |

### Phase C: 테스트 코드 및 검증 (예상 소요: 1.5시간)
| 순서 | 작업 | 파일 |
| :--- | :--- | :--- |
| C-1 | `MockBroadcaster` 개편 및 테스트용 헬퍼 수정 | `backend/internal/usecase/mock_test.go` |
| C-2 | 서비스별 테스트 코드 수정 및 검증 | `backend/internal/usecase/*_test.go` |

---

## 6. 검증 체크리스트

### 6.1 아키텍처 및 도메인 검증
- [x] `domain` 패키지가 외부 인프라/어댑터 계층을 참조하지 않음.
- [x] 모든 유즈케이스 메서드의 첫 번째 인자는 `context.Context` 임.
- [x] DB 트랜잭션 커밋 완료 직후에만 `Broadcaster.Broadcast`가 호출되도록 순서 보장.

### 6.2 유즈케이스 동작 검증
- [x] 캠프 활성화/종료 시 올바른 SSE 알림 이벤트 발송 확인.
- [x] 트랙 생성/삭제/교체/PIN 재생성 시 올바른 SSE 알림 이벤트 발송 확인.
- [x] 방문 시작/완료 시 corners, groups, tracks, track에 대해 알림 발송 확인.
- [x] 공지/다이렉트 메시지 발송 시 messages_changed 알림 발송 확인.
- [x] 기기 신뢰 상태(등록/승인/거절/회수/실패초기화) 변경 시 camp 스코프로 알림 발송 확인.
- [x] 진행자 PIN 검증 실패 5회 이상 누적 시 관리자 대시보드 알림(`lockout_alert`) 전송 확인.
