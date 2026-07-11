# Phase 09 — scenarios.md 매핑 및 최종 검증

> 목적: `scenarios.md`의 각 Gherkin 시나리오가 어느 자동화 테스트로 커버되는지, 또는 왜 진행자 앱 테스트 대상이 아닌지(서버 강제/관리자 전용)를 명시적으로 표로 남긴다. §00 §4 전체 체크리스트의 근거 자료.

## 1. Feature 1 — 조-코너 방문 처리

| 시나리오 | 담당 테스트 | 비고 |
|---|---|---|
| 정상적인 방문 시작과 종료 | `main_track_test`, `qr_scan_test` | |
| QR 스캔 불능 시 방문 시작과 종료 | `manual_checkin_test` | 종료 경로는 QR 상태와 무관하게 동일(main_track_test와 공유) |
| 종료 확인은 두 번 탭 | `main_track_test` | |
| 종료 확인 무장 상태 시간 초과 시 자동 취소 | `main_track_test` | |
| 이미 완료한 코너 재방문 스캔 거부 | `qr_scan_test` | `DUPLICATE_VISIT` 매핑 |
| 관리자 승인을 통한 예외적 재방문 허용 | — | 관리자 전용 처리(서버), 진행자 앱은 일반 스캔 성공 경로와 동일해 별도 테스트 불필요 |
| 트랙이 이미 사용 중일 때 시작 스캔 거부 | `main_track_test`(UI 은닉), `qr_scan_test`(`TRACK_BUSY` 방어적 매핑) | 대기열 없음 규칙의 UI 반영 |
| 프로그램 종료 시각까지 일부 코너 미방문 조 처리 | `main_track_test`(`campEnded`) | 리포트 집계는 관리자 앱 영역 |

## 2. Feature 2-c — 트랙 교체 (§00 §0-c 결정 반영)

| 시나리오 | 담당 테스트 | 비고 |
|---|---|---|
| 정상적인 트랙 교체(원안: 자동전환) | — | **이번 Plan에서 구현하지 않음.** 현재 계약상 `track_deleted`로 처리되어 `main_track_test`의 강제종료(trackDeleted) 케이스와 동일하게 커버됨. 원안 자동전환은 이슈 [#30](https://github.com/lsjtop10/cornermon/issues/30) |

**후속 조치**: `scenarios.md` Feature 2-c와 `screen-spec-facilitator.md` B8 항목에 "현재는 트랙 삭제와 동일 처리, 자동전환은 #30에서 추적" 각주를 추가한다(Phase 09 작업 항목 I-3).

## 3. Feature 3 — 진행자 인증

| 시나리오 | 담당 테스트 | 비고 |
|---|---|---|
| 신뢰 기기의 정상 로그인 | `pin_login_test` | |
| PIN 로그인 직후 코너·트랙 확인 | `track_confirm_test` | |
| 확인 모달에서 잘못된 배정 거부 | `track_confirm_test` | |
| 미등록 기기는 PIN 화면에 도달 불가 | `facilitator_router_test`, `device_pending_test` | |
| 잘못된 PIN 입력 | `pin_login_test` | |
| 삭제된 트랙의 옛 PIN 로그인 시도 | `pin_login_test` | 서버 응답 코드 기준으로 동일 매핑 로직 재사용, 별도 케이스 아님 |
| 신뢰 기기의 연속 실패 — 점증형 지연 | `pin_login_test` | 서버가 내려준 `retryAfterSeconds` 반영 여부만 검증(클라이언트 자체 카운트 없음) |
| 세션 스코프 위반 — 타 코너 데이터 접근 차단 | — | 서버 강제(403), 진행자 앱 UI엔 타 트랙 접근 경로 자체가 없음 |
| 세션은 유휴 시간과 무관하게 만료되지 않는다 | — | 클라이언트에 유휴 타임아웃 로직을 아예 두지 않는 설계로 자동 충족 |
| 관리자의 명시적 강제 로그아웃만 세션을 끊는다 | `main_track_test`(`forceLogout`) | |
| 트랙 삭제로 인한 세션 강제 종료 | `main_track_test`(`trackDeleted`) | |
| 코너학습 종료로 인한 세션 강제 종료 | `main_track_test`(`campEnded`) | |
| 세션 강제 종료는 BUSY 중에도 유예 없이 즉시 | `main_track_test` | BUSY 상태로 세팅한 채로 위 3케이스 재검증 |
| 관리자의 즉시 잠금 해제 | — | 관리자 전용 처리, 진행자 쪽은 통상 로그인 성공 경로와 동일 |

## 4. Feature 3-b — 기기 등록

| 시나리오 | 담당 테스트 | 비고 |
|---|---|---|
| 등록 요청과 동시에 토큰 발급 | `device_pending_test` | |
| 관리자의 등록 승인 | `device_pending_test` | `pending`→"계속하기" 버튼 노출 검증(실제 승인 확인은 §00 §0-c대로 B1에서) |
| 관리자의 등록 거절 | `device_pending_test` | |
| 행사 중 예비 기기의 긴급 등록 | — | 승인 시나리오와 동일 경로, 별도 케이스 아님 |
| 분실/도난 기기의 신뢰 회수 | `device_pending_test`(`revoked` 상태 렌더링) | 실시간 회수 감지는 이슈 #32 해결 전까지 불가 — 다음 앱 재시작/재시도 시에만 반영됨을 화면 문구로 안내 |
| 클라이언트가 기기정보를 조작해도 신뢰를 얻을 수 없음 | — | 서버 강제, 프론트 테스트 대상 아님 |
| 토큰이 보안저장소 아닌 방식으로 노출되면 탈취 위험 | 정적 점검(§5) | `SecureTokenStore`(flutter_secure_storage) 외 저장소 미사용 확인 |

## 5. Feature 5 — 메시지

| 시나리오 | 담당 테스트 | 비고 |
|---|---|---|
| 공지는 발송 시점 ACTIVE 트랙에만 노출 | — | 서버 필터링, 프론트는 GET 결과를 그대로 표시 |
| 공지 발송 이후 새 트랙은 과거 공지를 보지 못함 | — | 서버 로직 |
| 공지 읽음 여부는 트랙별로 추적됨 | `broadcast_inbox_test` | |
| 다이렉트 스레드는 트랙 생성과 동시에 빈 상태로 존재 | `track_direct_test` | |
| 진행자가 먼저 다이렉트 메시지를 보낼 수 있다 | `track_direct_test` | |
| 진행자는 자신의 트랙 스레드만 접근 가능 | — | 서버 강제, UI에 타 트랙 접근 경로 없음 |
| 트랙 삭제 후 이력 보존, 신규 메시지 불가 | — | 세션 종료 후 UI 접근 자체 불가 |
| 트랙 교체로 생성된 새 트랙은 새 스레드를 가짐 | — | 서버 로직 |
| 메시지 발신/수신은 감사 로그에 기록되지 않음 | — | 백엔드 감사로그 구현 문제, 프론트 무관 |

## 6. 정적 점검 (런타임 테스트가 아닌 항목)

- [ ] `grep -rl "shared_preferences" frontend/lib/{shared/auth,facilitator/session}` 결과 없음 — 토큰이 `SecureTokenStore` 경유로만 저장됨
- [ ] `grep -rl "package:cornermon/admin" frontend/lib/facilitator` 결과 없음
- [ ] `grep -rl "package:cornermon/facilitator" frontend/lib/shared` 결과 없음

## 7. 작업 단계 (문서 갱신)

| 순서 | 작업 | 파일 |
|---|---|---|
| I-1 | 위 매핑표 기준으로 Phase 08의 테스트 파일들이 실제로 존재·통과하는지 최종 확인 | `frontend/test/**` |
| I-2 | §6 정적 점검 3건 실행 및 결과 기록 | — |
| I-3 | `scenarios.md` Feature 2-c, `screen-spec-facilitator.md` B8에 "현재는 트랙 삭제와 동일 처리 — 이슈 #30" 각주 추가 | `docs/front/scenarios.md`, `docs/front/screen-spec-facilitator.md` |

## 8. 최종 완료 기준

`00_overview.md` §4와 이 문서 §1~§6을 모두 통과하면 이번 Plan(진행자 앱 전체 플로우, B8 제외)이 완료된 것으로 간주한다.
