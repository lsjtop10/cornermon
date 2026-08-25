# Phase 11 — A13 감사 로그 / A14 코너학습 종료 / A15 설정 (compact)

## 요구사항
감사 로그 필터/커서 조회(A13), 운영 모드 어디서든 "코너학습 종료" 확정→리포트 생성→캠프 목록
복귀(A14), 캠프 정보·병목 기준 수정(A15) 구현.

## 왜 이렇게 했는가
- **A13 컬럼 정렬 UI 제외**: screen-spec은 컬럼 클릭 정렬을 요구하지만 `GET /audit-logs`에
  `sort`/`order` 파라미터가 없고 커서 페이지네이션과 클라이언트 사이드 정렬은 근본적으로 충돌
  (더 보기로 다음 페이지를 불러올 때마다 정렬이 깨짐) — 정렬 UI 자체를 구현하지 않기로 확정하고
  screen-spec 옆에 각주로 근거 남김. "N/전체건"도 커서 기반이라 전체 건수를 알 수 없어 "현재까지
  N건 로드됨"으로 문구 변경.
- action 드롭다운은 enum을 내려주는 API가 없어, 하드코딩 후보 목록 대신 **첫 페이지 응답의 실제
  action 값으로 동적 구성**하기로 결정(추정 목록보다 정확).
- **A14 리포트 생성 흐름**: `POST /camps/{id}/end` 응답 설명에 리포트 관련 언급이 없고
  `reports/generate`가 독립 엔드포인트로 분리돼 있어, 서버가 자동 트리거한다는 screen-spec 원문
  해석을 기각하고 **클라이언트가 `endCamp` 성공 직후 `generateReport`를 명시적으로 이어서 호출**.
  리포트 생성 실패는 "종료" 자체의 실패로 취급하지 않고 캠프 목록으로는 정상 이동 + 경고 스낵바만
  표시(A12에서 재생성 가능하므로 완전한 실패가 아님).
- **버그 발견 및 수정**: `endCamp`/`generateReport`/`updateCamp` provider가 `retry: noRetry` 없이
  plain `@riverpod`라 400 응답도 Riverpod 기본 정책(무제한 재시도)에 걸려 에러 처리가 실제로는
  수십 초 지연되거나 아예 반영 안 되는 버그를 위젯 테스트 작성 중 발견 → 세 provider 모두
  `@Riverpod(retry: noRetry)` 추가(기존 `createCamp`와 동일 패턴으로 통일).
- A15 저장 액션은 `ConsumerState.ref.listen()`이 `build()` 중에만 호출 가능해 계획했던 위젯
  레벨 리스닝 패턴을 쓸 수 없다는 게 구현 중 드러나 `AsyncNotifier` 컨트롤러로 옮김(계획에 없던
  `UpdateCampController` 신규 추가, `start_camp_controller.dart`와 동일 패턴).
