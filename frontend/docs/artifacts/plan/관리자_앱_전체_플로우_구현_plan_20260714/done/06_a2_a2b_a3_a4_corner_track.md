# Phase 06 — A2 코너 상세 / A2B 트랙 일괄 관리 / A3 트랙 교체 / A4 PIN 전체 내보내기 (compact)

## 요구사항
코너 하나의 트랙 관리(A2, 인라인 편집·추가·PIN·교체·삭제), 캠프 전체 트랙 일괄 관리(A2B, 필터·
정렬·일괄 목표시간 변경·일괄 삭제), 트랙 교체 모달(A3, A2에 내장), 전체 PIN CSV 내보내기(A4,
A2B에 내장) 구현.

## 왜 이렇게 했는가
- **단건 코너 수정**은 `PATCH /corners/{id}`가 계약에 없어 `PUT /corners/bulk-update`를 1건
  배열로 호출 — 단건/일괄이 항상 동일한 provider를 쓰도록 통일.
- **단건 트랙 삭제**도 `DELETE /tracks/{id}` 단건 엔드포인트가 계약에 없어(`01`이 잘못 나열했던
  시그니처를 오류로 간주) `bulkDeleteTracks` 1건 배열로 구현 — 코너 단건 수정과 같은 패턴.
- PIN 내보내기: 단건(`GET /tracks/{id}/export`)은 JSON이라 확인 팝업+복사, 전체(`GET
  /tracks/export`)도 JSON이라 클라이언트에서 CSV를 생성해 `share_plus`로 공유(`printing`은 PDF
  전용이라 CSV엔 안 씀).
- 트랙의 `status`(ACTIVE/DELETED, 소프트 삭제 마커)와 `operationalStatus`(IDLE/BUSY, 코너
  운영 상태 필터 기준)를 구분 — A2B 상태 필터는 `operationalStatus` 기준.
- **A3 트랙 교체는 A2에서만 가능**하다고 확정, A2B 테이블에는 교체 액션을 넣지 않음 — screen-spec
  A2B 구성요소에 "교체" 액션이 명시돼 있지 않아서.
- 일괄 목표시간 변경은 "트랙 단위"가 아니라 "코너 단위"로 적용(트랙엔 `targetMinutes`가 없고
  코너에만 있음) — scenarios.md와 일치하지만 오해 방지를 위해 UI 문구에 명확히 표기.
- **A4 내보내기 이력**: 서버가 전용 이력 API를 주지 않아, 세션 로컬 상태(앱 재시작 시 소실) 대신
  `GET /audit-logs?action=<PIN 내보내기 액션명>`으로 조회하는 방향으로 사용자 결정 — 재시작 후에도
  이력이 유지되는 장점. 실제 백엔드가 이 액션을 감사 로그에 안 남기면 세션 로컬 상태로 폴백.
