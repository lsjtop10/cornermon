# DeviceRegistration 생성 시각 영속화 계획

## 목표

`DeviceRegistration`의 실제 등록 시각을 조회 시점이 아닌 영속 데이터로 보존한다.

## 작업

1. `device_registrations`에 `created_at` 컬럼을 추가하고 기존 행을 안전하게 백필한다.
2. `domain.DeviceRegistration`과 Postgres/sqlc 매핑에 `CreatedAt`을 추가한다.
3. 등록 생성 시 서비스의 `nowFn`으로 값을 설정하고, 모든 응답 DTO가 그 값을 사용하게 한다.
4. 생성·조회 시각의 보존 및 마이그레이션을 테스트한다.
