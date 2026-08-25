# Issue #94 — DB 마이그레이션 도구 도입 (golang-migrate) (compact)

Issue: #94 (https://github.com/lsjtop10/cornermon/issues/94)

## 요구사항
DB 스키마가 `db/schema.sql` 단일 파일로만 관리돼 점진적 스키마 변경(`ALTER TABLE`)·롤백·버전
추적 수단이 없음. 마이그레이션 도구 도입 + 서버 기동 시 자동 적용까지가 범위.

## 왜 이렇게 했는가
- goose 대신 **golang-migrate**(순수 SQL, 도메인 결합 없음) 채택 — goose의 Go 마이그레이션
  기능은 파일이 앱과 같은 바이너리로 컴파일돼 도메인 모델이 나중에 바뀌면 옛 마이그레이션의
  컴파일이 깨질 수 있는 문제가 있음.
- golang-migrate 공식 CLI 바이너리를 설치/래핑하지 않고, 이미 추가하는 pgx/v5 드라이버를
  재사용하는 얇은 자체 커맨드(`cmd/migrate-tool`)로 대체 — 기존 `cmd/cleanup-corners` 관례와
  일치, 별도 빌드 태그 관리 불필요.
- 데이터 백필처럼 도메인 로직이 필요한 작업은 범위 밖(사용자 확인) — 필요해지면 `cmd/` 아래
  별도 원샷 배치 커맨드로 분리.
- CI/CD 마이그레이션 파이프라인은 `.github/` 자체가 없어 범위 제외, 별도 이슈로 분리 제안.
- 운영 DB가 아직 없는 개발 단계라(사용자 확인) 베이스라인을 "이미 적용된 것으로 마킹"할 필요 없이
  처음부터 다시 적용.
