# Issue #46 — 대상 코너를 지정하는 트랙 교체 API (compact)

Issue: #46 (https://github.com/lsjtop10/cornermon/issues/46)

## 요구사항
`PUT /tracks/{id}/replace`에 필수 `newCornerId` body를 받아, 기존 코너와 대상 코너의 캠프
일치를 검증하고 삭제·재생성·migration target 저장을 단일 트랜잭션에서 수행하도록 구현.

## 왜 이렇게 했는가
- 기존 세션은 revoke하지 않고 새 트랙 ID를 migration target으로 저장 — 진행 중인 세션이 안전하게
  새 트랙으로 넘어갈 수 있게 함.
- 캠프 불일치 검사를 트랙 삭제나 PIN 생성 **이전**에 수행 — 실패 시 원본 상태를 그대로 보존하기
  위함.
- 평문 PIN은 repository나 감사 로그 metadata에 저장하지 않음.
