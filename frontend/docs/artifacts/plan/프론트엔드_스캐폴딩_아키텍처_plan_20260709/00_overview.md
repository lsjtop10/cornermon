# 프론트엔드(Flutter) 스캐폴딩 및 아키텍처 — 개요

> 상위 로드맵: [`docs/artifacts/plan/프로젝트_전체구조_구현방향_plan_20260709.md`](../../../../../docs/artifacts/plan/프로젝트_전체구조_구현방향_plan_20260709.md) §3, §6 프론트엔드 트랙(F-1~F-6)을 구체화하는 하위 Plan.
> 근거 문서: `docs/technical-design.md` §0-c/§0-d(Flutter 확정, 단일 레포·멀티 엔트리포인트 확정안), `docs/design-system.md`, `docs/domain/domain-model.md`, `docs/front/screen-spec*.md`, `api/openapi.yaml`(2757줄, 확정된 API 계약).

## 0. 이번 Plan에서 확정한 것 (사용자 확인 완료)

기존 문서가 결정하지 않은 3가지 핵심 아키텍처 축과, 계층 구조 자체를 이번 대화에서 확정했다:

| 축 | 결정 | 근거 |
|---|---|---|
| 상태관리 | **Riverpod** (`flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`) | SSE 스트림을 `StreamProvider`로 캡슐화하기 쉽고, 트랙/관리자 세션 같은 전역 상태를 `BuildContext` 없이 관리하기 쉬움. 위젯 테스트 시 `ProviderScope(overrides:)`로 목업 주입 용이 |
| 라우팅 | **go_router** | 캠프 상태(PENDING/ACTIVE/ENDED)별 사이드바 3모드 리다이렉트, PIN 로그인 직후 확인 모달(B1-b) 강제 경유 같은 조건부 내비게이션을 선언적으로 표현 |
| OpenAPI→Dart 코드생성 | **openapi-generator-cli (`dart-dio` generator)** | 상위 로드맵 §5에서 이미 권장·확정된 도구와 동일. 산출물은 `frontend/lib/shared/api/gen`에 **커밋**한다(생성기 미설치 상태로도 클론 직후 빌드 가능하게) |
| 계층 구조 | **FSD(Feature-Sliced Design)의 철학을 프로젝트 규모에 맞게 유연 적용** — 강제 세그먼트(ui/model/api) 없이 `shared → entities → features → app` 단방향 의존만 지킨다 | 아래 §0-a 참고 |

### 0-a. 계층 구조 결정 배경

최초 설계는 `common/domain`에 백엔드 `internal/domain`의 9개 엔티티(Camp, Group, Corner, Track, Visit, Badge, Message, DeviceRegistration, AuditLog)를 1:1로 미러링하고, 생성된 DTO(`common/api/gen`)를 mapper로 그 도메인 모델에 변환하는 구조였다. 이는 다음 이유로 폐기했다:

- 백엔드 도메인 계층은 **상태 전이 규칙(불변식)의 실제 소유자**라 별도 순수 계층이 필요하지만, 클라이언트는 그 규칙을 소유하지 않는다 — 모든 쓰기는 서버 API를 거치고, 클라이언트는 서버가 반환한 최신 스냅샷만 신뢰하는 읽기 전용 뷰다. 상태 전이 메서드 없는 "도메인 모델"은 사실상 데이터 구조체이므로, 백엔드 구조를 그대로 복제할 이유가 없다.
- `domain-model.md`의 유비쿼터스 언어 1:1 대응 원칙(`implement.md`)은 **이름 매핑 규칙**이지 **구조 복제 규칙**이 아니다.
- 화면 간 파생 로직 중복(예: `Group.isFinished`, 상태뱃지 색상)은 도메인 엔티티 계층 전체가 아니라, 생성 DTO 위에 얹는 가벼운 extension으로 충분히 해결된다.

이에 따라 **FSD(Feature-Sliced Design)의 철학**을 이 프로젝트 규모(진행자 9화면 + 관리자 20화면, 소규모 팀)에 맞게 유연하게 적용하기로 확정했다:

1. **데이터 소스 통합**: `shared/api/gen`에 생성된 DTO(`api.Camp`, `api.Group` 등)를 최전선 데이터 모델로 인정한다. 별도 도메인 모델 클래스와 mapper는 전면 삭제한다.
2. **응집도 강화**: 특정 DTO에 클라이언트 전용 파생 로직·UI 상태 바인딩이 필요하면, **각 앱(`admin`/`facilitator`)의 `entities/` 레이어 안에서** DTO 위에 `extension`(또는 `extension type`)을 얹어 그 맥락에 응집시킨다. 관리자와 진행자가 같은 DTO(`api.Group`)를 서로 다른 관점으로 파생시킬 수 있으므로 `entities`는 앱별로 분리한다(공유하지 않음).
3. **결합도 차단**: `admin/**`와 `facilitator/**`는 서로를 절대 참조하지 않는다. 오직 `shared/`(디자인시스템, API DTO, 공통 라우터/인증 인프라)만 공유한다. 세션 상태(`AdminSession`/`TrackSession`/`DeviceTrust`)도 각 앱에만 존재하는 개념이므로 `shared`가 아니라 각 앱의 `session/`에 둔다.
4. **세그먼트 유연 통합**: `features/<name>/` 아래 `ui/model/api` 같은 하위 폴더를 강제하지 않는다. 파일이 몇 개 안 되면 화면 위젯과 그 상태 provider를 같은 폴더에 나란히 둔다(예: `features/qr_scan/qr_scan_screen.dart`, `features/qr_scan/qr_scan_state_provider.dart`).

## 1. 이 Plan의 범위 (스코프 경계)

**포함**: `/frontend` 전체 디렉토리 골격, 계층별 책임과 의존성 규칙, 두 앱(관리자/진행자)의 라우팅 트리와 화면 스캐폴딩(빈 Scaffold + 목적 주석 + 라우트 등록), 공유 API/인증/디자인시스템 계층과 앱별 entities/session 계층의 타입·시그니처, 테스트 인프라 골격.

**제외** (후속 Plan에서 화면/기능 단위로 별도 작성):
- A0~A15, B0~B8 각 화면의 실제 레이아웃·인터랙션 구현(레이아웃 요구사항은 `screen-spec-admin.md`/`screen-spec-facilitator.md`에 이미 상세 기술되어 있음 — 이번 Plan은 그 화면이 "어느 파일에, 어떤 라우트로, 어떤 provider를 주입받아" 존재할지까지만 정한다)
- 실제 서버 연동 동작 검증(백엔드 usecase/adapter가 상위 로드맵 M3~M6 기준 아직 미착수 — 이 Plan의 화면들은 Mock 서버 또는 `packages:mocktail`/Riverpod override로만 우선 검증)
- 상위 로드맵 §4에 명시된 도메인 미결정 사항(코너 이름 중복, `POST /corners` 부분 실패 트랜잭션 범위 등)에 의존하는 화면 디테일

**실행 순서 근거**: 상위 로드맵이 "진행자 앱(B0~B8, 9개 화면)을 관리자 앱(A0~A15, 20개 화면)보다 먼저" 만들라고 정했다(공유 기반을 좁은 화면 세트로 먼저 검증). 이 Plan의 Phase 순서(02→03→04→05→06)도 동일하게 **공유 계층(디자인시스템→API→인증/실시간) 완성 후 진행자 골격을 먼저, 관리자 골격을 나중에** 만든다.

## 2. 핵심 기술 유즈케이스 (이 골격이 지원해야 하는 것)

| 우선순위 | 유즈케이스 | 근거 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 관리자/진행자가 완전히 분리된 두 바이너리로 빌드된다(번들ID·아이콘·앱이름 분리) | technical-design.md §0-d | **프로덕션 핵심** — 진행자 기기에 관리자 코드가 존재하면 안 됨(공격 표면) |
| **P0** | UC-2: `api/openapi.yaml` 변경 시 `make gen` 한 번으로 Dart 모델/클라이언트가 동기화된다 | workflow/repo.md, 상위 로드맵 §5 | **프로덕션 핵심** — Go↔Flutter 계약 불일치 원천 차단 |
| **P0** | UC-3: SSE 단방향 스트림을 구독하고, 재연결 시 항상 전체 스냅샷을 다시 받는다(델타 유실 걱정 없음) | technical-design.md §2.3-b | **프로덕션 핵심** — 관리자 대시보드/진행자 메인화면 실시간성의 기반 |
| **P0** | UC-4: 트랙 PIN 세션(무만료, 강제종료 3종 즉시 반영)과 관리자 액세스/리프레시 세션(silent refresh)이 보안 저장소에만 저장된다 | domain-model.md §2.4, technical-design.md §2.2-a/b | **프로덕션 핵심** — 인증이 이 시스템 전체 보안 경계의 출발점 |
| **P0** | UC-5: 캠프 상태(PENDING/ACTIVE/ENDED)에 따라 관리자 사이드바가 3모드 중 하나로만 렌더링되고, 허용 안 된 라우트는 가드로 차단된다 | screen-spec-admin.md 전체 내비게이션 구조, design-system.md §3.2 | **프로덕션 핵심** |
| P1 | UC-6: 디자인 토큰(색상 4+1색·타이포·스페이싱)이 라이트/다크 모두에서 WCAG AA를 만족하며 화면 전역에 일관 적용된다 | design-system.md §1, §6, §7 | 시각 일관성, 접근성 |
| P1 | UC-7: 화면 위젯을 실제 네트워크 없이 Riverpod override만으로 렌더링·테스트할 수 있다 | plan.md §5 "검증 방법" 요구 | 품질 검증용 |
| P2 | UC-8: 핵심 시나리오(시작 스캔→종료 확인 2회 탭) 1건이 실기기/에뮬레이터 통합테스트로 재현된다 | scenarios.md Feature 1 | 회귀 검증용, 후속 확장 |

## 3. `/frontend` 전체 디렉토리 구조

```
frontend/                                    # Flutter 프로젝트 루트(pubspec.yaml 위치)
├── Makefile                                 # gen/dev-admin/dev-facilitator 타겟(루트 Makefile에서 include, Phase 01)
├── openapitools.json                        # openapi-generator-cli 설정(dart-dio generator)
├── pubspec.yaml
├── analysis_options.yaml                    # import_lint 규칙(admin↔facilitator 상호 참조 금지, shared→admin/facilitator 역참조 금지 검증)
├── lib/
│   ├── main_admin.dart                      # runApp + ProviderScope(overrides: [sessionTokenSourceProvider ← AdminSessionTokenSource])
│   ├── main_facilitator.dart                # runApp + ProviderScope(overrides: [sessionTokenSourceProvider ← TrackSessionTokenSource])
│   ├── shared/
│   │   ├── api/
│   │   │   ├── gen/                         # openapi-generator-cli 산출물 — 손 수정 금지, 커밋함(Phase 01). api.Camp/api.Group 등이 최전선 데이터 모델
│   │   │   ├── ids.dart                     # CampId/GroupId/CornerId/TrackId/BadgeId/... (extension type, String 값을 타입으로만 구분)
│   │   │   ├── client/
│   │   │   │   ├── api_client.dart          # gen의 Dio 인스턴스 조립
│   │   │   │   └── auth_interceptor.dart    # SessionTokenSource(아래 shared/auth)만 참조 — admin/facilitator 세션 provider 직접 참조 금지(Phase 04)
│   │   │   ├── sse/
│   │   │   │   ├── sse_client.dart          # EventSource 격 Stream 래퍼(하트비트/좀비연결 감지, Phase 04)
│   │   │   │   ├── admin_event_stream.dart  # GET /events/admin 구독 StreamProvider
│   │   │   │   └── track_event_stream.dart  # GET /events/track/{trackId} 구독 StreamProvider
│   │   │   └── providers/                   # Riverpod repository-provider — api.* DTO를 그대로 반환(mapper 없음, Phase 03)
│   │   │       ├── camp_providers.dart
│   │   │       ├── group_providers.dart
│   │   │       ├── corner_track_providers.dart
│   │   │       ├── badge_providers.dart
│   │   │       ├── message_providers.dart
│   │   │       ├── report_providers.dart
│   │   │       └── audit_log_providers.dart
│   │   ├── auth/                            # Phase 04 — 두 앱이 실제로 공유하는 인프라만
│   │   │   ├── secure_token_store.dart      # Keychain/Keystore 래퍼(flutter_secure_storage)
│   │   │   └── session_token_source.dart    # abstract interface class SessionTokenSource — AuthInterceptor가 의존하는 DI 경계
│   │   ├── design_system/                   # Phase 02
│   │   │   ├── tokens/
│   │   │   │   ├── colors.dart              # design-system.md §1 전 토큰
│   │   │   │   ├── typography.dart          # §2
│   │   │   │   └── spacing.dart             # §3.1
│   │   │   ├── theme/
│   │   │   │   ├── admin_theme.dart
│   │   │   │   └── facilitator_theme.dart
│   │   │   └── widgets/                     # §4 공유 컴포넌트
│   │   │       ├── status_badge.dart        # §1.2 4색+아이콘
│   │   │       ├── app_button.dart          # §4.2 Primary/Secondary/Destructive/Icon-only
│   │   │       ├── confirm_modal.dart       # §4.4 하드블록/소프트확인/단일버튼 3종
│   │   │       ├── empty_state.dart         # §4.8
│   │   │       └── connection_banner.dart   # §4.7
│   │   └── router/
│   │       └── redirect_guards.dart         # 두 앱 라우터가 공유하는 가드 헬퍼(세션 만료 감지 등)
│   ├── admin/                                # Phase 06
│   │   ├── app.dart                          # AdminApp(MaterialApp.router)
│   │   ├── router/admin_router.dart          # A0~A15 GoRoute 트리 + 캠프 상태별 가드
│   │   ├── session/
│   │   │   ├── admin_session_provider.dart      # 액세스/리프레시, silent refresh(§2.2-b) — admin 전용 개념
│   │   │   └── admin_session_token_source.dart  # SessionTokenSource 구현체(Phase 04 DI)
│   │   ├── entities/                         # api.* DTO 위 admin 전용 파생 로직(extension) — screens/features가 아닌 여기서만 파생
│   │   │   ├── group_ext.dart                # 예: AdminGroupX on api.Group { statusColor, completedCountLabel 등 }
│   │   │   └── camp_ext.dart
│   │   ├── features/                         # 디렉토리명에서 화면 코드 제거 — screen-spec-admin.md 코드는 주석으로만 매핑
│   │   │   ├── login/                    # A0
│   │   │   ├── setup_wizard/             # A0-b
│   │   │   ├── camp_list/                # A0-c
│   │   │   ├── badge_precreate/          # A0-d
│   │   │   ├── start_camp/               # A0-e
│   │   │   ├── dashboard/                # A1
│   │   │   ├── corner_detail/            # A2
│   │   │   ├── track_bulk_manage/        # A2B — A3(트랙교체)·A4(전체 PIN 내보내기)도 이 화면에서 진입하는 모달/버튼으로 통합
│   │   │   ├── group_list/               # A5
│   │   │   ├── group_detail/             # A6
│   │   │   ├── duplicate_visit_approve/  # A7
│   │   │   ├── device_registration/      # A8
│   │   │   ├── lockout_session_manage/   # A9
│   │   │   ├── broadcast/                # A10
│   │   │   ├── track_direct/             # A11
│   │   │   ├── report/                   # A12
│   │   │   ├── audit_log/                # A13
│   │   │   ├── end_camp/                 # A14
│   │   │   └── settings/                 # A15
│   │   └── widgets/                          # 여러 feature가 공유하는 admin 전용 위젯(feature 하나에 속하지 않음)
│   │       ├── sidebar/admin_sidebar.dart    # 3모드(운영/준비/리포트전용, §3.2)
│   │       ├── corner_status_card.dart       # §4.1
│   │       └── sortable_data_table.dart      # §4.5-b 정렬/필터 공통 패턴
│   └── facilitator/                          # Phase 05
│       ├── app.dart                          # FacilitatorApp
│       ├── router/facilitator_router.dart    # B0~B8 스택 라우트 + 트랙세션/기기신뢰 가드
│       ├── session/
│       │   ├── device_trust_provider.dart       # PENDING/APPROVED/REJECTED/REVOKED — facilitator 전용 개념
│       │   ├── track_session_provider.dart      # 트랙 PIN 세션 + 강제종료 3종 — facilitator 전용 개념
│       │   └── track_session_token_source.dart  # SessionTokenSource 구현체(Phase 04 DI)
│       ├── entities/                         # api.* DTO 위 facilitator 전용 파생 로직(extension)
│       │   ├── group_ext.dart                # 예: FacilitatorGroupX on api.Group { 진행자 관점의 표시용 파생값 }
│       │   └── track_ext.dart
│       ├── features/                          # 디렉토리명에서 화면 코드 제거 — screen-spec-facilitator.md 코드는 주석으로만 매핑
│       │   ├── device_pending/           # B0
│       │   ├── pin_login/                # B1
│       │   ├── track_confirm/            # B1-b
│       │   ├── main_track/               # B2
│       │   ├── qr_scan/                  # B3
│       │   ├── manual_checkin/           # B4
│       │   ├── visit_summary/            # B5
│       │   ├── broadcast_inbox/          # B6
│       │   ├── track_direct/             # B7
│       │   └── track_replaced_modal/     # B8
│       └── widgets/                          # 여러 feature가 공유하는 facilitator 전용 위젯
│           ├── pin_otp_input.dart            # §4.6 숨은 input 1개 + 6칸 표시 전용
│           ├── double_tap_confirm_button.dart # 종료확인 2회탭 무장 패턴
│           └── qr_scan_frame.dart
├── test/                                     # Phase 07
│   ├── shared/
│   ├── admin/
│   └── facilitator/
└── integration_test/                          # Phase 07
```

각 `features/<name>/` 디렉토리는 최소 `<name>_screen.dart` 1개 파일로 시작한다. 화면별 상태 provider가 필요해지면 `ui/model` 같은 강제 하위 폴더 없이 같은 폴더에 나란히 둔다(예: `features/qr_scan/qr_scan_screen.dart`, `features/qr_scan/qr_scan_state_provider.dart`). 파일이 늘어나 정리가 필요해질 때만 후속 Plan에서 하위 폴더를 도입한다.

## 4. 계층별 책임과 의존성 규칙

| 계층 | 의존 가능 대상 | 의존 금지 대상 | 근거 |
|---|---|---|---|
| `shared/api/gen` | (생성기 산출물, 수정 금지) | — | 재생성 시 통째로 덮어써짐 |
| `shared/api/ids` | 순수 Dart | `dio`, `flutter_riverpod` | 타입 안전 ID는 프레임워크 의존 없는 순수 값 타입 |
| `shared/api/{client,sse,providers}` | `shared/api/gen`, `shared/api/ids`, `shared/auth`(interceptor의 `SessionTokenSource`만) | `shared/design_system`, `admin/**`, `facilitator/**` | API 계층은 화면도, 디자인도, 특정 앱의 세션 구현도 몰라야 함 |
| `shared/auth` | `shared/api/ids` | `admin/**`, `facilitator/**` | **DI 경계**: `session_token_source.dart`는 추상 인터페이스만 정의하고 구현체를 모른다 — 구현은 각 앱의 `session/`이 제공하고 `main_admin.dart`/`main_facilitator.dart`가 Riverpod `overrideWith`로 주입한다(§4-a 참고) |
| `shared/design_system` | 순수 Flutter(Material만) | `shared/api/**` | 디자인 토큰/컴포넌트는 도메인을 몰라야 재사용성 유지 — 상태(BUSY/IDLE 등)는 enum 파라미터로만 주입받는다 |
| `admin/session`, `facilitator/session` | `shared/api/**`, `shared/auth`(인터페이스 구현) | 반대편 앱, `shared/design_system` | 세션은 앱별 개념이지만 API/DI 경계에는 의존 |
| `admin/entities`, `facilitator/entities` | `shared/api/gen`(대상 DTO), `shared/api/ids` | `flutter_riverpod`, `go_router`, 반대편 앱 | DTO 위 순수 파생 로직(extension)만 — 상태관리·라우팅과 무관 |
| `admin/features`, `facilitator/features` | 같은 앱의 `entities`, `session`, `widgets`, `shared/**` | 반대편 앱 전체 | 화면+상태를 한 묶음으로 관리 |
| `admin/**` | `shared/**` 전체 | `facilitator/**` | technical-design.md §0-d "단방향 의존 금지" |
| `facilitator/**` | `shared/**` 전체 | `admin/**` | 상동 |

### 4-a. `AuthInterceptor`의 DI 경계 (신규 확정)

`shared/api/client/auth_interceptor.dart`는 계층상 `admin/session`·`facilitator/session`보다 **아래**에 있으므로, 토큰 조회·401 처리를 위해 그 위 계층의 `AdminSession`/`TrackSession` provider를 직접 import하면 FSD의 단방향 의존 규칙이 깨진다. 이를 막기 위해:

- `shared/auth/session_token_source.dart`에 `abstract interface class SessionTokenSource { String? get currentAccessToken; Future<void> onUnauthorized(); }`와, 기본 구현이 없는 `sessionTokenSourceProvider`(호출 시 `UnimplementedError`)를 정의한다.
- `AuthInterceptor`는 오직 `ref.read(sessionTokenSourceProvider)`만 참조한다.
- 각 앱이 자신의 세션 provider를 감싸는 구현체를 제공한다: `admin/session/admin_session_token_source.dart`의 `AdminSessionTokenSource`(401 시 `AdminSession.silentRefresh()` 위임), `facilitator/session/track_session_token_source.dart`의 `TrackSessionTokenSource`(401 시 트랙 세션은 유휴 타임아웃이 없으므로 즉시 강제종료 처리로 위임 — silent refresh 대상이 아님).
- 합성 지점(composition root)인 `main_admin.dart`/`main_facilitator.dart`가 `ProviderScope(overrides: [sessionTokenSourceProvider.overrideWith(...)])`로 각각의 구현체를 주입한다.

이는 백엔드의 의존성 역전 원칙(`domain`/`usecase`가 인터페이스를 선언하고 `adapter`가 구현을 주입, `CLAUDE.md` "Two non-negotiable architecture rules" 2번)과 동일한 패턴을 프론트에도 그대로 적용한 것이다.

**생성 코드 이름 충돌 처리**: `api/openapi.yaml`의 스키마명(`Camp`, `Group`, `Corner`, `Track`, `Badge`, `Message`, `AuditLog`)이 domain-model.md 유비쿼터스 언어를 그대로 쓴 이름이라, 다른 계층에서 동명의 타입을 새로 만들면 이름이 겹친다. 따라서 `shared/api/gen`은 항상 `import '../gen/lib/api.dart' as api;`처럼 **`api.` 접두사로만 import**한다 — `features`에서 `api.Group`처럼 직접 참조하는 것은 허용되지만(이제 DTO가 곧 최전선 모델이므로), 생성된 `*Api` 서비스 클래스(`api.GroupApi` 등)를 `features`가 직접 인스턴스화하는 것은 금지 — HTTP 호출은 반드시 `shared/api/providers`를 거친다.

## 5. Phase 목차

| Phase 파일 | 내용 | 상위 로드맵 대응 | 선행조건 |
|---|---|---|---|
| [01_scaffold_and_toolchain.md](01_scaffold_and_toolchain.md) | 프로젝트 생성, flavor 분리, 코드젠 파이프라인, Makefile | F-1 (일부) | 없음 |
| [02_design_system.md](02_design_system.md) | 컬러/타이포/스페이싱 토큰, 테마, 공유 위젯 5종 | F-1 (일부) | 01 |
| [03_domain_and_api_layer.md](03_domain_and_api_layer.md) | 공유 API 계층(provider), 앱별 entities 확장 | F-2 (일부) | 01 |
| [04_auth_and_realtime.md](04_auth_and_realtime.md) | 보안 토큰 저장, `SessionTokenSource` DI, 세션(관리자/트랙), 기기신뢰, SSE | F-2 (일부) | 01, 03 |
| [05_facilitator_app_skeleton.md](05_facilitator_app_skeleton.md) | 진행자 라우팅+가드, B0~B8 스캐폴딩 | F-3, F-4 | 02, 03, 04 |
| [06_admin_app_skeleton.md](06_admin_app_skeleton.md) | 관리자 라우팅+3모드 가드, A0~A15 스캐폴딩 | F-5, F-6 | 02, 03, 04 |
| [07_test_infrastructure.md](07_test_infrastructure.md) | 단위/위젯/통합 테스트 인프라 | (로드맵에 명시 안 됐으나 plan.md 검증 요구 대응) | 05 또는 06 중 하나 완료 |

## 6. 전체 검증 체크리스트 (Phase별 상세 체크리스트는 각 파일 참고)

### 6.1 아키텍처
- [ ] `admin/**`와 `facilitator/**`가 서로를 import하지 않는다
- [ ] `shared/**` 어디에도 `admin/**`, `facilitator/**` import가 없다(`grep -rl "package:cornermon/admin\|package:cornermon/facilitator" frontend/lib/shared` 결과 없음)
- [ ] `shared/api/client/auth_interceptor.dart`가 `admin/session`·`facilitator/session`을 직접 import하지 않고, 오직 `shared/auth/session_token_source.dart`의 `SessionTokenSource` 인터페이스만 참조한다
- [ ] `main_admin.dart`/`main_facilitator.dart` 각각이 `sessionTokenSourceProvider`를 자신의 구현체로 override한다
- [ ] `admin/entities`, `facilitator/entities` 어디에도 `package:flutter_riverpod`, `package:go_router` import가 없다(DTO 위 순수 파생 로직만)
- [ ] `admin/features`, `facilitator/features` 어디에서도 생성된 `*Api` 서비스 클래스(`api.GroupApi` 등)를 직접 인스턴스화하지 않는다(전부 `shared/api/providers` 경유)
- [ ] `shared/api/gen` 아래 파일에 사람이 수동으로 수정한 흔적이 없다(재생성 시 git diff로 확인)

### 6.2 파이프라인
- [ ] `make gen` 한 번으로 `api/openapi.yaml`의 전 스키마가 `lib/shared/api/gen`에 Dart 클래스로 생성된다
- [ ] `flutter run -t lib/main_admin.dart --flavor admin`과 `-t lib/main_facilitator.dart --flavor facilitator`가 각각 다른 앱 이름/아이콘의 독립 바이너리로 설치된다
- [ ] `flutter analyze`, `flutter test`가 매 Phase 종료 시점에 그린

### 6.3 명명 일관성
- [ ] `admin/entities`, `facilitator/entities`의 extension 대상 타입(`api.Camp`, `api.Group` 등)과 파생 게터 이름이 domain-model.md 유비쿼터스 언어와 1:1 대응한다(예: `GroupStatus.atCorner` ↔ "진행중 AT_CORNER")
- [ ] `implement.md` "코드의 명명 규칙은 domain-model.md와 1:1 일치" 원칙을 각 Phase 완료 시 재확인

## 7. 다음 액션
1. 이 개요와 Phase 01~07을 사용자 검토 후, `implement.md`에 따라 새 워크트리 사용 여부를 먼저 확인하고 Phase 01부터 순차 착수한다.
2. Phase 05(진행자) 완료 후 Phase 06(관리자) 착수 전, 상위 로드맵 §4의 도메인 미결정 사항이 그 사이 확정됐는지 재확인한다(A2B/A5 등 일부 화면이 그 결정에 의존).
