# 진행자 세션 트랙 마이그레이션 타겟 영속화 (compact)

Issue: #199

## 요구사항
트랙 교체 시 세션에 `migrationTargetTrackID`를 메모리에서 설정·저장하지만
`facilitator_sessions` 테이블에 해당 컬럼이 없어 DB에 반영되지 않고, 재조회 시 항상 `None`으로
복원돼 진행자가 "no migration target" 에러를 받던 버그. in-memory mock repository를 쓰는 기존
테스트는 도메인 객체를 그대로 보관해 이 버그를 잡지 못했음.

## 왜 이렇게 했는가
- `migration_target_track_id` 컬럼을 `ON DELETE SET NULL`로 추가 — 트랙이 실제 삭제되는 경우
  (현재는 소프트 삭제라 발생 안 하지만 FK 안전장치)에도 세션 조회 자체가 깨지지 않게 함.
- DB 복원 전용 raw setter(`SetMigrationTargetTrackID`)를 기존 `SetRevokedAt`과 동일한 컨벤션으로
  추가 — 비즈니스 전이 메서드(`SetMigrationTarget`)와 리포지토리 복원 전용 메서드의 역할을 분리.
