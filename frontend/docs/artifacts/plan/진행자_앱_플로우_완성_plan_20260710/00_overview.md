# 진행자 앱 전체 플로우 완성 — 개요

> 선행 Plan: [`프론트엔드_스캐폴딩_아키텍처_plan_20260709`](../프론트엔드_스캐폴딩_아키텍처_plan_20260709/00_overview.md) — 그 Plan의 §1 "제외" 항목("화면별 실제 레이아웃 구현은 후속 Plan에서")에 해당하는 후속 작업이 이 Plan이다.
> 근거 문서: `docs/front/screen-spec-facilitator.md`(B0~B8), `docs/front/scenarios.md`(Feature 1/2-c/3/3-b/5), `docs/domain/domain-model.md`, `docs/technical-design.md` §2.3(SSE 하이브리드), `docs/design-system.md`, `api/openapi.yaml`(2769줄, 확정된 API 계약).
> 작업 브랜치: `feat/facilitator-app-flow` (워크트리 미사용, 사용자 확인됨).

## 0. 착수 전 조사에서 확인한 사실

### 0-a. 선행 Plan은 "골격"만 완료됐고 진행자 화면은 실제로 하나도 없다

`프론트엔드_스캐폴딩_아키텍처_plan_20260709`의 Phase 05(진행자 라우팅+B0~B8 스캐폴딩)는 git 이력상 실행된 적이 없다. 실제로 존재하는 것은:

- `frontend/lib/facilitator/{app.dart, entities/*, session/*}` — `app.dart`는 `Text('Facilitator App')` 뿐인 빈 스텁이고, `main_facilitator.dart`는 `facilitator/app.dart`를 쓰지 않고 자체 `FacilitatorApp`을 중복 정의하고 있다(Phase 01에서 정리).
- `TrackSession`/`DeviceTrust` provider는 상태 모델과 로그인/등록 메서드가 구현돼 있어 재사용 가능하다.
- `frontend/lib/shared/api/providers/*`에 camp/group/corner_track/badge/message/audit_log/auth_device_trust provider는 있으나 **visit provider(방문 시작/종료/조회)가 없다** — Phase 03 계획에 애초에 빠져 있었다.
- `frontend/lib/shared/api/sse/` 디렉토리 자체가 없다 — SSE 클라이언트(하트비트/좀비연결 감지)와 `trackEvents` StreamProvider가 전혀 구현되지 않았다(04_auth_and_realtime.md D-8/D-9가 미완료로 남아 있던 항목).
- `facilitator/router/`, `facilitator/features/` 디렉토리 자체가 없다 — B0~B8 화면과 라우터 가드가 전혀 없다.
- `frontend/test/`, `frontend/integration_test/` 디렉토리 자체가 없다.

즉 이 Plan은 "레이아웃 채우기"가 아니라 **라우팅 + SSE 인프라 + visit provider + 10개 화면(B8 제외, §0-c 참고) + 테스트 인프라를 처음부터 구현**하는 범위다.

### 0-b. 검증 범위(사용자 확인됨)

이 환경은 GUI가 없어 실기기/에뮬레이터 구동이 불가능하다. **검증은 `flutter analyze` + 자동화 unit/widget 테스트(Riverpod override 기반, 실 네트워크 없음)로 한정**한다. 로컬 백엔드 기동이나 실기기 수동 검증은 이번 Plan의 범위에 포함하지 않는다.

### 0-c. 화면 명세·시나리오와 API 계약이 어긋나는 2곳 — 사용자 확인 완료, GitHub 이슈로 분리

조사 중 `api/openapi.yaml`(오늘 반영된 SSE 하이브리드 알림+풀 재설계 포함)을 직접 대조한 결과, 문서 원안과 계약이 정면으로 어긋나는 지점이 있었다. 사용자와 협의해 아래와 같이 확정했다:

1. **B8 트랙 교체 자동전환**: `scenarios.md` Feature 2-c/`screen-spec-facilitator.md` B8은 "재PIN 없이 자동 세션전환"을 요구하지만, 현재 계약상 트랙 교체는 트랙 삭제와 동일하게 처리되어 기존 기기는 `track_deleted` 알림만 받고 강제로 PIN 재입력 화면(B1)으로 전환된다. 이 교체 전용 자동전환을 가능케 할 이벤트·엔드포인트가 계약에 없다.
   → **결정: 이번 Plan은 B8을 별도 화면으로 만들지 않는다.** 트랙 교체는 B2의 기존 강제종료 처리 경로(`trackDeleted` 사유)로 흡수되어 동일하게 동작한다. 자동전환 기능은 [이슈 #30](https://github.com/lsjtop10/cornermon/issues/30)로 분리해 백엔드 계약이 보강되면 별도 Plan으로 진행한다.
2. **B0 승인 자동 감지**: 미승인 기기가 자기 등록 상태를 조회할 API가 계약에 없다(관리자 전용 `GET /device-registrations`뿐).
   → **결정: 라우터 가드가 `pending` 상태도 PIN 로그인 화면 진입을 허용**하고, B0에 "승인받으셨다면 계속하기" 수동 버튼을 두어 진행하게 한 뒤, 실제 승인 여부는 B1의 실 PIN 로그인 호출(403 `DEVICE_NOT_TRUSTED`)이 최종 게이트 역할을 한다(§03 상세). 전용 상태조회 API는 [이슈 #32](https://github.com/lsjtop10/cornernon/issues/32)로 분리했다.

두 이슈 모두 백엔드 작업이며 이번 Plan(프론트엔드)의 스코프 밖이다. 백엔드 구현 상태(컴파일 여부 등)는 이번 Plan에서 검증 대상이 아니다 — 프론트엔드는 오직 `api/openapi.yaml` 문서 계약을 기준으로 구현한다.

### 0-d. B1 "관리자에게 도움 요청" 링크 — 사용자 확인 완료, 기능 자체를 제거

당초 `screen-spec-facilitator.md` B1은 점증형 지연(PIN 잠금) 중 "관리자에게 도움 요청" 링크로 B7(다이렉트 메시지)에 딥링크하도록 정의했다. 조사 결과 이 링크는 구조적으로 구현 불가능했다 — B7(`GET/POST /tracks/{trackId}/messages`)은 트랙ID와 `TrackAuth` 세션이 모두 있어야 하는데, PIN 잠금 상태는 정의상 PIN이 계속 틀렸다는 뜻이라 어느 트랙인지 확정된 적이 없고(또는 강제로그아웃으로 세션이 이미 무효화됐고), 그 상태에서 열 수 있는 트랙 스코프 스레드가 애초에 없다.

사용자와 협의한 결과 **이 링크는 기능 자체를 제거하기로 확정**했다(B8/B0처럼 백엔드 개선 이슈로 분리하지 않음) — 대안 채널을 새로 만들 값어치가 없다고 판단한 근거: `scenarios.md` Feature 3 "신뢰 기기의 연속 실패 - 점증형 지연"에 따르면 5회 이상 실패 시 관리자 대시보드에 `lockout_alert`가 이미 자동으로 뜬다. 즉 실제로 개입이 필요해지는 시점엔 진행자가 먼저 손쓰지 않아도 관리자가 이미 알고, 그보다 낮은 단계(3~4회, 5초/30초 지연)는 잠깐 기다리면 되는 수준이라 도움 요청 채널이 커버할 실질적 틈새가 없다. `screen-spec-facilitator.md` B1은 이미 이 결정을 반영해 갱신했다. §03 참고.

### 0-e. API 날짜/시간은 전부 UTC — 표시 시 로컬 변환 필수 (조사 누락, 사용자 지적으로 확인)

`api/openapi.yaml` 상단 설명(22~24행 — 최초 조사 때 paths 섹션으로 바로 넘어가느라 놓쳤던 부분)에 명시: "모든 `date-time` 필드는 UTC 기준 ISO 8601 형식(`YYYY-MM-DDTHH:mm:ssZ`)으로 표현된다. 클라이언트는 필요 시 표시 단계에서 로컬 타임존(예: KST +09:00)으로 변환해야 한다." 생성된 Dart 클라이언트는 `Iso8601DateTimeSerializer`(built_value 표준, `frontend/lib/shared/api/gen/lib/src/serializers.dart:195`)를 쓰므로 `DateTime.parse`가 UTC로 올바르게 파싱된다(`.isUtc == true`).

**영향 정리**:
- `DateTime.difference()`로 계산하는 경과시간/소요시간(B2 타이머, B5 duration/deviation)은 두 시각 모두 같은 절대 순간을 정확히 표현하는 한 **변환 없이도 이미 정확**하다 — 절대 순간의 차이는 타임존 표기와 무관하므로 이 부분은 원래부터 문제가 없었다(§04에 이미 그렇게 설계돼 있었음, 지금 재확인만 함).
- 반면 사람에게 **절대 시각 자체**(예: "몇 시에 메시지가 왔다")를 보여주는 곳은 반드시 `.toLocal()` 후 포맷해야 한다 — 이번 Plan에서는 B6(공지함)/B7(다이렉트 메시지)의 타임스탬프 표시가 해당하며 기존 §07 초안엔 이 요구가 명시돼 있지 않았다(갱신함).

## 1. 핵심 유즈케이스

| 우선순위 | 유즈케이스 | 근거 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 미신뢰 기기는 어떤 경로로도 PIN 화면에 도달할 수 없다(하드 블록) | scenarios.md Feature 3-b | 보안 핵심 |
| **P0** | UC-2: PIN 로그인 성공 직후 B1-b 확인을 건너뛰고 B2에 도달하는 경로가 없다 | scenarios.md Feature 3 | 보안 핵심 |
| **P0** | UC-3: 시작 스캔(QR/수동) → 종료 확인(2회 탭)까지 방문 1건이 정확히 처리된다(소요시간·편차 포함) | scenarios.md Feature 1 | **프로덕션 핵심 로직** |
| **P0** | UC-4: 트랙 삭제·강제 로그아웃·캠프 종료 SSE 알림 수신 시 BUSY 여부와 무관하게 즉시 B1로 강제 전환된다 | scenarios.md Feature 3, domain-model §2.4 | 보안 핵심 |
| **P0** | UC-5: 트랙이 BUSY일 때 시작 액션 자체가 화면에서 숨겨져 오조작을 원천 차단한다 | scenarios.md Feature 1 "트랙이 이미 사용 중일 때" | UI 레벨 안전장치 |
| **P1** | UC-6: SSE 알림 수신 시 해당 scope만 REST로 재조회하고, 40초 무응답 시 스스로 재연결한다 | technical-design.md §2.3-b | 실시간성 |
| **P1** | UC-7: 공지·다이렉트 메시지를 조회·발신하고 안읽음 뱃지가 갱신된다 | scenarios.md Feature 5 | 보조 기능 |
| **P1** | UC-8: 모든 화면이 Riverpod override만으로 네트워크 없이 렌더링·검증된다 | 사용자 확인(§0-b) | 품질 검증 |
| P2 | UC-9: PIN 연속 실패 시 서버가 내려준 `retryAfterSeconds`를 그대로 반영한 점증형 지연 UI | scenarios.md Feature 3 "점증형 지연" | UX 보조 |

## 2. Phase 목차

| Phase 파일 | 내용 | 선행조건 |
|---|---|---|
| [01_shared_infra_gaps.md](01_shared_infra_gaps.md) | SSE 클라이언트, visit provider, 진행자 전용 위젯 3종, `main_facilitator.dart` 정리 | 없음 |
| [02_router_and_guards.md](02_router_and_guards.md) | `facilitator_router.dart`, 가드 로직(DeviceTrust `pending` 허용 포함) | 01 |
| [03_b0_b1_b1b_auth_flow.md](03_b0_b1_b1b_auth_flow.md) | B0 기기등록대기, B1 PIN로그인, B1-b 확인모달 | 01, 02 |
| [04_b2_main_track.md](04_b2_main_track.md) | B2 메인 트랙 화면(핵심 루프) | 01, 02, 03 |
| [05_b3_b4_visit_entry.md](05_b3_b4_visit_entry.md) | B3 QR스캔, B4 수동처리 | 01, 04 |
| [06_b5_visit_summary.md](06_b5_visit_summary.md) | B5 방문완료요약 | 05 |
| [07_b6_b7_messages.md](07_b6_b7_messages.md) | B6 공지함, B7 다이렉트메시지 | 01, 02 |
| [08_test_infrastructure.md](08_test_infrastructure.md) | 테스트 헬퍼 + 전 화면 unit/widget 테스트 | 03~07 |
| [09_verification_checklist.md](09_verification_checklist.md) | scenarios.md 시나리오 ↔ 테스트 매핑, 최종 체크리스트 | 08 |

## 3. 전체 아키텍처 원칙 (기존 결정 승계, 변경 없음)

`프론트엔드_스캐폴딩_아키텍처_plan_20260709` 00_overview.md §4의 계층 규칙(FSD 유연 적용, `shared→entities→features→app` 단방향 의존, `admin`↔`facilitator` 상호 참조 금지)을 그대로 따른다. `analysis_options.yaml`의 `import_lint` 규칙(`facilitator_no_admin`, `shared_no_apps`, `facilitator_entities_no_deps`)으로 기계적으로 강제되므로 이번 Plan에서 새 규칙을 추가하지 않는다.

화면 코드(B0~B8)는 디렉토리명이 아니라 주석으로만 매핑한다: `facilitator/features/<name>/<name>_screen.dart`.

## 4. 전체 검증 체크리스트 (Phase별 상세는 각 파일 §4, 종합은 09번 파일)

- [ ] `flutter analyze`가 전체 그린 (facilitator 신규 코드 기준)
- [ ] `flutter test`가 전체 그린
- [ ] `admin/**`, `facilitator/**` 상호 참조 없음 (`import_lint` 통과)
- [ ] scenarios.md Feature 1/3/3-b/5의 각 시나리오가 §09 매핑표의 자동화 테스트로 1건 이상 커버됨
- [ ] B8 관련 스펙 이탈 사항이 문서(`screen-spec-facilitator.md`, `scenarios.md`)에 갱신되고 이슈 #30 링크가 남음
