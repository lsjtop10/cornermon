# 관리자 앱 전체 플로우 구현 — 개요

> 대상 저장소: `frontend/` (Flutter). 백엔드 코드는 참조하지 않고 `api/swagger.yaml`(OpenAPI 2.0/Swagger 계약, 2026-07-14 최신)과 `docs/front/screen-spec-admin.md`, `docs/front/scenarios.md`, `docs/domain/domain-model.md`만 근거로 삼는다.
> 진행자 앱(`frontend/lib/facilitator/**`) 빌드가 현재 깨져 있는 문제는 이 plan의 범위 밖이다 — 손대지 않는다.
> 이 디렉토리의 각 파일은 `workflow/plan.md` 템플릿(유즈케이스 우선 정의 → 객체 정의 → 작업 단계 → 검증 체크리스트)을 따른다. 구현 시 `workflow/implement.md`(커밋 300줄 내외, 도메인 유비쿼터스 언어 1:1 매칭)를 준수한다.

## 0. 이 문서를 읽는 법

이후 파일(`01_*.md` ~ `14_*.md`)은 이 문서에서 확정한 **① 스크린 인벤토리 ② API 결정사항 ③ 공통 컨벤션**을 전제로 작성되어 있다. 각 파일을 구현하는 담당자는 반드시 이 문서를 먼저 읽어야 한다. 화면 레이아웃의 세부 사항(정확한 문구, 배치)은 이 plan이 아니라 `docs/front/screen-spec-admin.md`의 해당 화면 ID 절을 그대로 따르되, §2(API 결정사항)에 명시된 지점은 screen-spec의 서술보다 이 문서를 우선한다(screen-spec 작성 시점 이후 API가 확정/변경됐기 때문).

## 1. 유즈케이스 및 화면 인벤토리

`docs/front/screen-spec-admin.md`의 A0~A15 20개 화면 중 **A7(중복방문 예외 승인)은 이번 범위에서 완전히 제외**한다 — `POST /visits/exception-approve` 계약이 존재하지 않고, 사용자 확인 결과 "해당 기능 삭제됨"으로 결정됨. A6(조 상세)에도 A7 진입점(모달 호출 버튼)을 넣지 않는다.

| 우선순위 | 화면 ID | 화면명 | 담당 plan 파일 |
|---|---|---|---|
| **P0** | 골격 | 라우팅 가드·3모드 사이드바·세션 부트스트랩 | `02_admin_skeleton_router_sidebar.md` |
| **P0** | A0, A0-b | 로그인, 초기 설정 마법사 | `03_a0_a0b_login_setup_wizard.md` |
| **P0** | A0-c, A0-d, A0-e | 캠프 목록, QR 배지 사전 생성, 코너학습 시작 | `04_a0c_a0d_a0e_camplist_badge_start.md` |
| **P0** | A1 | 대시보드 | `05_a1_dashboard.md` |
| **P0** | A2, A2B, A3, A4 | 코너 상세, 트랙 일괄 관리, 트랙 교체, PIN 전체 내보내기 | `06_a2_a2b_a3_a4_corner_track.md` |
| **P1** | A5, A6 | 조 현황 목록, 조 상세 | `07_a5_a6_group_status.md` |
| **P1** | A8, A9 | 기기 등록 관리, PIN 잠금해제/세션 관리 | `08_a8_a9_device_session.md` |
| **P1** | A10, A11 | 메시지(공지/다이렉트) | `09_a10_a11_messages.md` |
| **P1** | A12 | 리포트 | `10_a12_report.md` |
| **P2** | A13, A14, A15 | 감사 로그, 코너학습 종료, 설정 | `11_a13_a14_a15_audit_end_settings.md` |
| **P0**(인프라) | — | Admin API 코드젠 파이프라인 복구 + 부족한 provider 보강 | `01_api_codegen_sync.md` |
| **P1**(인프라) | — | Admin SSE 연동(알림 수신 → REST 재조회) | `12_admin_sse_integration.md` |
| **P0**(인프라) | — | 테스트 인프라(공통 fixture/mock) | `13_test_infrastructure.md` |
| — | — | 전체 검증 체크리스트 | `14_verification_checklist.md` |

권장 실행 순서: `01` → `02` → (`03`~`11`은 서로 화면이 겹치지 않아 병렬 가능하되, `02` 골격이 먼저 끝나야 라우트에 화면을 매달 수 있음) → `12`(각 화면이 REST로 먼저 동작한 뒤 SSE로 "재조회 트리거"를 얹는 방식이므로 반드시 마지막) → `13`은 `01`과 병행 가능 → `14`는 전체 완료 후.

## 2. API 결정사항 (screen-spec-admin.md보다 이 문서가 우선)

### 2.1 A7 제외
`POST /visits/exception-approve` 없음. A6 화면에 "중복방문 예외 승인" 진입점을 만들지 않는다.

### 2.2 A2 단건 코너 수정은 `PUT /corners/bulk-update`를 1건 배열로 호출
`PATCH /corners/{id}`는 계약에 없다. `BulkUpdateCornersRequest.corners`에 요소 1개(`{id, name?, targetMinutes?}`)만 담아 호출한다. A2(코너 상세 인라인 편집), A15(설정 없음 — 코너 목표시간은 A2/A2B에만 있음), A2B(다중 선택 일괄 변경) 모두 이 엔드포인트 하나로 통일한다.

### 2.3 Admin SSE — "알림만 오고 스냅샷은 안 옴" (notify-then-refetch)
`GET /api/v1/camps/{campId}/events/admin` (AdminAuth, campId 경로 파라미터로 격리됨 — PR #61로 확정). 각 이벤트는 `data:` 라인에 `SSENotification` JSON만 담고 있다:
```json
{"event": "tracks_updated", "scope": {"kind": "camp"}}
```
- `event` enum 12종: `tracks_updated`, `track_updated`, `corners_updated`, `groups_updated`, `camp_updated`, `messages_changed`, `track_deleted`, `track_replaced`, `session_revoked`, `camp_ended`, `device_registration_updated`, `lockout_alert`.
- `scope.kind`는 `camp` 또는 `track`(+`trackId`) — Admin 스트림에서는 대체로 `camp`만 온다(트랙 단위 스코프는 진행자 스트림용).
- **페이로드에 상태 스냅샷이 없다.** 이벤트를 받으면 해당 리소스의 REST GET을 다시 호출해 최신값을 가져와야 한다 — 화면 구현 시 "SSE로 즉시 반영"이 아니라 "SSE는 트리거, 실데이터는 REST 재조회"로 이해할 것.
- best-effort — 유실 시 재전송 없음. 버퍼(서버 측) full이면 연결이 끊기므로 클라이언트는 재연결 후 REST로 강제 재조회해야 한다(연결 재수립 시점에 무조건 1회 전체 재조회 — `12_admin_sse_integration.md`에서 상세).
- 이 연동은 화면별 REST 구현이 끝난 뒤 `12_admin_sse_integration.md`에서 한 번에 배선한다. `03`~`11`의 각 화면 plan은 **풀to리프레시/재진입 시 재조회**로 1차 동작을 명시하고, "SSE 트리거 연결"은 `12`로 위임한다고 표시되어 있다.

### 2.4 캠프 컨텍스트는 URL 경로 파라미터(`campId`)로 전달
`/camps/{campId}/corners`, `/camps/{campId}/groups`, `/camps/{campId}/tracks`, `/camps/{campId}/reports/*`, `/camps/{campId}/messages/broadcast`, `/camps/{campId}/events/admin` 전부 동일 패턴. screen-spec-admin.md가 "미정"으로 남겨뒀던 지점이지만 이제 확정됐다 — 관리자가 캠프 목록(A0-c)에서 캠프를 선택하면 그 `campId`를 세션/라우터 상태로 들고 다니며 이 경로들에 채운다(`02_admin_skeleton_router_sidebar.md`에서 정의하는 `selectedCampIdProvider` 참고).

### 2.5 배지 내보내기(A0-d)는 서버가 PDF를 만들지 않는다
`GET /badges/export`는 `ExportBadgesResponse`(JSON, 미배정 배지 배열)를 반환한다 — "클라이언트가 직접 PDF 인쇄 및 레이아웃 구성을 할 수 있도록"이라고 명시되어 있다. screen-spec-admin.md의 "스티커 PDF로 내보내기" 문구는 유지하되, **PDF 생성 자체는 클라이언트 책임**이다(`pdf`/`printing` 패키지 추가 필요 — `04_a0c_a0d_a0e_camplist_badge_start.md`에서 다룸).

### 2.6 PIN 내보내기는 단건/전체가 서로 다른 포맷
- `GET /tracks/{id}/export` (단건, A2 트랙 행) → `application/pdf`, 서버가 PDF를 직접 생성해 내려준다.
- `GET /tracks/export` (전체, A4/A2B) → `text/csv`, 서버가 CSV를 내려준다.
같은 "PIN 내보내기"라도 처리 방식이 다르므로 공용 위젯을 만들 때 포맷을 하드코딩하지 말 것.

사용자 피드백: PIN내보내기도 서버에서 PDF를 직접 생성해 내려주는 방향보다는 JSON데이터 클라이언트 

### 2.7 목록 API에 서버사이드 필터/정렬 없음
`GET /camps/{campId}/groups`, `GET /camps/{campId}/tracks`, `GET /camps/{campId}/corners`, `GET /badges`, `GET /audit-logs`(단, `actor`/`action`/`result` 필터와 `before`/`limit` 커서 페이지네이션은 있음 — `sort`/`order`는 없음) 모두 전체 목록을 반환하고 필터·정렬은 클라이언트 사이드로 처리한다(screen-spec-admin.md "확인 필요 사항"에서 이미 클라이언트 사이드로 가정했던 부분과 일치, 실제 계약으로 재확인됨).

### 2.8 메시지 — 공지는 캠프 스코프, 다이렉트는 트랙 스코프
`GET/POST /camps/{campId}/messages/broadcast` (2026-07-14 PR #62로 캠프 격리 확정, `sent_at` 오름차순), `GET /messages/broadcast/{id}/receipts`, `GET/POST /tracks/{trackId}/messages`(다이렉트, `sent_at` 오름차순). `MessageResponse.channelType`(`BROADCAST`/`DIRECT`), `senderRole`(`ADMIN`/`TRACK`)로 발신자를 구분해 A10/A11의 말풍선 정렬(관리자 우측/트랙 좌측)에 쓴다.

## 3. 공통 아키텍처 컨벤션 (기존 코드베이스 그대로 따름)

`frontend/docs/artifacts/plan/프론트엔드_스캐폴딩_아키텍처_plan_20260709/03_domain_and_api_layer.md`에서 확립된 3계층 패턴을 그대로 따른다 — 이번 plan에서 새로 정의하지 않는다:

1. **`shared/api/gen`** (`cornermon_api_gen` 패키지, path dependency) — `api/swagger.yaml`에서 자동 생성된 DTO/`*Api` 클라이언트. 직접 import해서 쓰지 않는다.
2. **`shared/api/providers/*.dart`** — `@riverpod` 함수/클래스가 생성 DTO(`api.Camp`, `api.Group` 등)를 **그대로** 반환. HTTP 호출은 이 계층 안에서만 일어난다. 이미 `camp_providers.dart`, `group_providers.dart`, `corner_track_providers.dart`, `badge_providers.dart`, `message_providers.dart`, `report_providers.dart`, `visit_providers.dart`, `audit_log_providers.dart`, `auth_device_trust_providers.dart`가 존재 — 관리자 화면에서 재사용하되 **campId 파라미터가 추가로 필요한 메서드는 시그니처를 갱신**해야 한다(`01_api_codegen_sync.md` 참고, 코드젠이 최신 swagger를 반영하지 않아 현재 이 provider들은 구버전 엔드포인트를 호출 중).
3. **`admin/entities/*.dart`** — DTO 위에 관리자 관점 파생 로직만 extension으로 얹는다(`group_ext.dart`, `camp_ext.dart` 이미 존재). `dio`/`flutter_riverpod`/`go_router` import 금지.
4. **`admin/features/<screen>/`** — 실제 화면 위젯. `admin/entities`와 `shared/api/providers`만 의존.

디렉터리 네이밍은 `docs/front/screen-spec-admin.md`의 화면명을 한글이 아닌 영문 스네이크케이스로 옮긴 것을 쓴다(예: A1 대시보드 → `dashboard`, A2B 트랙 일괄 관리 → `track_bulk_manage`) — 각 plan 파일에서 정확한 디렉터리명을 명시한다.

## 4. 알려진 제약 및 이번 범위에서 다루지 않는 것

- 진행자 앱 빌드 오류 수정 — 범위 밖.
- 관리자 iPad 세로 모드 최적화 — screen-spec 원문대로 "지원하되 최적화 대상 아님"만 지킨다.
- A12 리포트의 시계열/운영지표 탭(analytics-model.md §1.5, §1.6) — screen-spec에서도 범위 제외로 명시됨, 이번 plan도 동일.
- 코너 이름 중복 시 `POST /corners` 부분 실패 트랜잭션 처리 — 계약(`CreateTracksRequest`류)에 부분 실패 응답 스키마가 없어 "전체 실패 시 어떤 코너도 생성되지 않는다"는 전제로 UI를 만들고, 서버가 부분 성공을 반환하면 버그로 취급한다(별도 계약 없이는 UI가 부분 실패를 구분할 방법이 없음).

## 5. 검증 개요

각 화면 plan 파일 말미의 체크리스트를 모두 통과한 뒐, `14_verification_checklist.md`에서 전체 플로우(로그인 → 캠프 없음/있음 분기 → 준비 모드 → 코너학습 시작 → 운영 모드 전 화면 → 코너학습 종료 → 리포트 전용 모드)를 실기기(`flutter run -t lib/main_admin.dart --flavor admin`)로 1회 수동 구동한다.
