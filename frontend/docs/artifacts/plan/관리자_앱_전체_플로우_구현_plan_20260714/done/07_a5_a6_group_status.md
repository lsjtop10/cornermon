# Phase 07 — A5 조 현황 목록 / A6 조 상세(순회표) (compact)

## 요구사항
조 현황 목록(필터/정렬), 배지 QR 스캔 또는 목록 선택으로 조 등록, 조 상세(순회표+방문 이력)
구현. A7(중복방문 예외 승인)은 계약(`POST /visits/exception-approve`) 자체가 없어 범위에서
완전히 제외 — screen-spec 원문의 관련 문장은 무시.

## 왜 이렇게 했는가
- **배지 등록 API 비대칭 해결(핵심 결정)**: screen-spec은 "스캔"과 "목록에서 선택" 두 탭이 동일한
  결과(새 조 생성+배지 배정)를 내야 한다고 요구하는데, 실제 계약은 `POST /badges/{id}/register`
  (`groupId`—기존 조에 배정)와 `POST /badges/scan-register`(`groupName`—이름으로 새 조 생성)가
  비대칭. `groupId` 필드가 사실은 "이름"이라는 해석은 필드명/타입(UUID) 불일치로 기각. 대신
  **두 탭 모두 `scanRegisterBadge`로 수렴**(목록에서 고른 배지의 `qrPayload`를 스캔한 것처럼
  넘김)하기로 사용자 검토 후 확정 — 백엔드에 신규 `POST /groups` API를 요청하는 대안보다 이쪽이
  나음. `registerBadge`(`badgeId` 기반)는 이 화면에서 쓰지 않고, 별도 유즈케이스(배지 재배정)용으로
  남겨둠.
- "마지막 스캔 시각" 컬럼은 `GroupResponse`에 대응 필드가 없어 표시하지 않음 — "계약에 없으면
  만들지 않는다" 원칙.
- `group_ext.dart`의 `isFinished`는 서버가 이제 `isFinished` 필드를 직접 내려주므로 클라이언트
  계산 로직을 삭제하고 서버 필드를 그대로 사용하도록 변경.
