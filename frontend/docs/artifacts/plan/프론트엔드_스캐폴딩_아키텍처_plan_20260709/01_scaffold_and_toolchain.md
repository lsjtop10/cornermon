# Phase 01 — 프로젝트 스캐폴딩 및 코드생성 파이프라인

> 선행조건: 없음(이 저장소에서 `frontend/`는 완전히 빈 디렉토리 — 이번 Phase가 최초 스캐폴딩).
> 목적: Flutter 프로젝트를 생성하고 관리자/진행자 두 독립 바이너리로 빌드되는 멀티 엔트리포인트·flavor 구조를 갖추며, `api/openapi.yaml` → Dart 코드생성 파이프라인과 루트 `Makefile`을 정비한다.
> 근거: technical-design.md §0-c(Flutter), §0-d(단일 레포·멀티 엔트리포인트), 상위 로드맵 §5(코드생성 도구 확정: openapi-generator-cli, 산출물 커밋)·§6 F-1.

## 1. 유즈케이스
| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-1: `flutter create`로 단일 Flutter 프로젝트 생성, iOS/Android 각각 admin/facilitator flavor 분리 | 프로덕션 핵심 — 배포 산출물 분리의 전제 |
| **P0** | UC-2: `make gen`으로 `api/openapi.yaml` → `lib/shared/api/gen`이 재생성됨 | 프로덕션 핵심 |

## 2. 객체/설정 정의

### 2.1 `openapitools.json` (개념 스케치 — 실제 값은 openapi-generator-dart-dio 문서 기준으로 채움)
```json
{
  "generator-cli": { "version": "7.x" },
  "generators": {
    "cornermon-dart-client": {
      "generatorName": "dart-dio",
      "inputSpec": "../api/openapi.yaml",
      "output": "lib/shared/api/gen",
      "additionalProperties": {
        "pubName": "cornermon_api_gen",
        "nullSafe": true
      }
    }
  }
}
```
- **책임**: `api/openapi.yaml`의 모든 `components.schemas`(Camp, Corner, Track, TrackSummary, Group, CornerProgress, Badge, VisitSummary, VisitStatus, DeviceRegistration, Message, BroadcastReceipt, AuditLog, AdminSession, CampReport, SseEvent 등 — 실제 목록은 openapi.yaml 참고)와 전 엔드포인트(`/camps`, `/tracks/{id}/replace`, `/events/admin` 등)의 Dart 모델·API 클라이언트 메서드를 생성.
- SSE 엔드포인트(`/events/admin`, `/events/track/{trackId}`)는 dart-dio generator가 스트리밍 응답을 그대로 지원하지 않으므로, 생성된 클라이언트는 **요청 URL/헤더 조립 용도로만** 쓰고 실제 스트림 파싱은 Phase 04의 `SseClient`가 담당한다(Dio의 `ResponseType.stream` 저수준 API 사용).

### 2.2 루트 Makefile 타겟 (프론트 관련分만, 백엔드 타겟은 별도 Plan에서 추가)
```makefile
.PHONY: gen dev-admin dev-facilitator

gen:
	cd api && openapi-generator-cli generate -c ../frontend/openapitools.json
	# (백엔드 oapi-codegen 호출은 backend 트랙 Plan에서 이 타겟에 이어붙임)

dev-admin:
	cd frontend && flutter run -t lib/main_admin.dart --flavor admin

dev-facilitator:
	cd frontend && flutter run -t lib/main_facilitator.dart --flavor facilitator
```
- **책임**: `make gen`은 결정적(deterministic)이어야 한다 — 동일 `openapi.yaml` 입력에 매번 동일한 산출물을 만들어 diff 노이즈를 없앤다.

### 2.3 엔트리포인트 (실제 구현은 이후 Phase, 여기선 최소 스텁만)
```dart
// lib/main_admin.dart
void main() { runApp(const AdminApp()); } // AdminApp 정의는 Phase 06
```
```dart
// lib/main_facilitator.dart
void main() { runApp(const FacilitatorApp()); } // FacilitatorApp 정의는 Phase 05
```

## 3. 작업 단계

| 순서 | 작업 | 파일/경로 |
|---|---|---|
| A-1 | `flutter create --org com.cornermon --project-name cornermon .` 실행 후 데모 스캐폴딩(`lib/main.dart`, 기본 테스트) 제거 | `/Users/lsjtop10/projects/cornermon/frontend/` |
| A-2 | `main_admin.dart`, `main_facilitator.dart` 최소 스텁 생성(§2.3) | `frontend/lib/main_admin.dart`, `frontend/lib/main_facilitator.dart` |
| A-3 | Android `productFlavors` 2개(`admin`/`facilitator`) 추가 — applicationIdSuffix, 앱 라벨, 아이콘 리소스 분리 | `frontend/android/app/build.gradle` |
| A-4 | iOS Xcode scheme 2개(Admin/Facilitator) + 각각 다른 `PRODUCT_BUNDLE_IDENTIFIER`/`PRODUCT_NAME`/`AppIcon` 설정 | `frontend/ios/Runner.xcodeproj/*`, `frontend/ios/Runner/Info.plist` |
| A-5 | `openapitools.json` 작성(§2.1) | `frontend/openapitools.json` |
| A-6 | `openapi-generator-cli` 1회 실행해 `lib/shared/api/gen` 최초 생성, 커밋(로드맵 §5 원칙 — gitignore 안 함) | `frontend/lib/shared/api/gen/` |
| A-7 | `pubspec.yaml`에 핵심 의존성 추가: `flutter_riverpod`, `riverpod_annotation`(+ dev: `build_runner`, `riverpod_generator`), `go_router`, `flutter_secure_storage`, `dio`(생성 클라이언트 런타임 의존성), `mobile_scanner`(QR, B3) | `frontend/pubspec.yaml` |
| A-8 | 루트 Makefile에 `gen`/`dev-admin`/`dev-facilitator` 타겟 추가(§2.2) — 기존 Makefile 없으므로 신규 생성, 백엔드 타겟 추가 여지를 주석으로 남김 | `/Users/lsjtop10/projects/cornermon/Makefile` |
| A-9 | `analysis_options.yaml`에 `import_lint`(또는 동등 패키지) 규칙 초안 추가 — `admin/**`가 `facilitator/**`를 import 못하게(반대도 동일), `admin/entities/**`, `facilitator/entities/**`가 `dio`/`flutter_riverpod`/`gen/**`를 import 못하게 | `frontend/analysis_options.yaml` |

예상 소요시간: **3~4시간** (iOS/Android flavor 설정이 가장 시간이 걸리는 부분 — Xcode scheme은 GUI 조작이 섞여 자동화 스크립트만으로 끝나지 않음).

## 4. 검증
- [ ] `flutter run -t lib/main_admin.dart --flavor admin`과 `flutter run -t lib/main_facilitator.dart --flavor facilitator`가 동일 기기에 **서로 다른 앱 이름/아이콘**으로 나란히 설치된다(하나가 다른 하나를 덮어쓰지 않음)
- [ ] `make gen` 실행 후 `git status`에서 `lib/shared/api/gen` 아래 파일들이 `api/openapi.yaml`의 스키마 수와 대응하는 개수만큼 생성됨을 확인
- [ ] `flutter analyze` 통과(빈 스캐폴딩 상태 기준)
- [ ] `import_lint` 규칙이 실제로 위반을 잡아내는지 — 임시로 `facilitator/app.dart`에 `import '../../admin/app.dart';`를 추가했을 때 `flutter analyze`가 에러를 내는지 확인 후 되돌림
