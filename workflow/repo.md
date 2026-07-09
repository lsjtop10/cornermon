# 레포지토리 관리 규칙 

본 프로젝트는 모노레포 멀티 프로젝트 방식으로 관리합니다. 구체적인 방법은 다음과 같습니다.

- **API 정의 스키마 도입 및 코드 제너레이션 자동화**:
REST API를 쓴다면 OpenAPI 3.0 (Swagger), 실시간 통신이 많다면 gRPC / Protocol Buffers를 도입합니다.
이를 통해 두 레포지토리의 코드 제너레이션을 자동화하여 타입 안정성을 확보합니다.
- **통합 스크립트 도구 활용**:
최상위 루트에 Makefile을 두어 make gen (코드 생성), make dev-server (Go 서버 로컬 실행), make dev-app (Flutter 실행) 같은 단순한 명령어로 개발 환경을 일원화합니다.