# Phase 04 — A0-c 캠프 목록 / A0-d QR 배지 사전 생성 / A0-e 코너학습 시작 (compact)

## 요구사항
관리자 로그인 직후 진입 화면(A0-c 캠프 목록), 배지 대량 생성·PDF 인쇄용 스티커 내보내기(A0-d),
준비 모드→운영 모드 전환 트리거(A0-e) 세 화면 구현.

## 왜 이렇게 했는가
- `GET /camps`는 screen-spec 원문(`?status=`)과 달리 쿼리 파라미터가 없음 — 전체 목록을 받아
  클라이언트에서 상태별로 그룹핑.
- PDF 생성은 서버 API가 없어 클라이언트 책임으로 확정, `pdf`+`printing` 패키지 신규 추가.
  "iPad에서 직접 인쇄 안 함, 다른 기기로 넘겨 인쇄" 요구사항에 맞춰 `Printing.layoutPdf`(인쇄
  다이얼로그 직행)가 아니라 `Printing.sharePdf`(공유 시트)를 명시적으로 채택.
- 배지 테이블의 "등록된 조" 컬럼: `Badge`가 조 이름을 직접 갖지 않는 것은 설계 오류가 아니라
  의도(배지는 배지 정보만) — `selectedCampIdProvider`로 이미 가진 campId로 `groupListProvider`를
  함께 watch해 로컬 조인, 매칭 실패 시 "배정됨"으로만 폴백 표시.
- A0-e 성공 후 `campDetailProvider`를 invalidate하지 않고 캐시를 직접 갱신 — "재조회 없이 즉시
  전환" 요구사항 충족을 위해 `02` 라우터 문서가 확정한 캐시 갱신 메커니즘을 그대로 재사용.
