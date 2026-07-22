# Issue #193 모바일 내보내기 저장 위치 선택 계획

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: PDF 기기에 저장 | 사용자가 PDF 저장 위치를 선택하고, 취소하면 조용히 복귀한다. | **프로덕션 핵심 로직** |
| **P0** | UC-2: 전체 PIN XLSX 기기에 저장 | 사용자가 XLSX 저장 위치를 선택하고, 올바른 이름·MIME으로 저장한다. | **프로덕션 핵심 로직** |
| **P0** | UC-3: 다른 앱으로 공유 | 기존 플랫폼 공유 시트를 파일 형식별로 그대로 연다. | **프로덕션 핵심 로직** |
| P1 | UC-4: 저장/공유 오류 피드백 | 저장 취소와 오류를 구별해 각 화면의 기존 SnackBar 규칙을 보존한다. | 테스트/검증용 |

## 2. 설계와 책임

- `lib/shared/export/export_file.dart` **(신규)**: `file_saver` 네이티브 파일 선택기를 Provider 포트로 감싼다. `saveAs`의 nullable path를 결과값으로 변환하여 취소를 성공/오류와 분리하고, PDF/XLSX의 확장자와 MIME type을 한 곳에서 보장한다.
- 기능별 controller는 API 조회와 PDF/XLSX 바이트 생성을 책임진다. `exportAndSave`는 공통 저장 포트만 의존하고, `exportAndShare`는 기존 `Printing`/`SharePlus` 포트만 의존한다.
- 위젯은 공통 `ExportActionButton`으로 `기기에 저장`과 `다른 앱으로 공유`를 명시적으로 노출하고, controller 결과의 취소/성공/오류를 화면별 기존 SnackBar 규칙에 맞춰 표시한다.

## 3. 구현 단계

### Phase A: 공유 저장 경계 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `ExportFile`, 저장 Provider와 PDF/XLSX factory 추가 | `/home/lsjtop10/projects/cornermon/.worktrees/issue-193/frontend/lib/shared/export/export_file.dart` **(신규)** |
| A-2 | `file_saver` 의존성 추가 | `/home/lsjtop10/projects/cornermon/.worktrees/issue-193/frontend/pubspec.yaml` **(기존 파일 확장)** |

### Phase B: 기능별 controller와 UI (예상 90분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | PDF·XLSX 저장 action 추가 | `/home/lsjtop10/projects/cornermon/.worktrees/issue-193/frontend/lib/admin/features/**` **(기존 파일 확장)** |
| B-2 | 저장/공유 선택 UI 연결 | `/home/lsjtop10/projects/cornermon/.worktrees/issue-193/frontend/lib/shared/export/export_action_menu.dart` 및 각 화면 **(기존 파일 확장)** |
| B-3 | 저장 성공·취소·실패 및 공유 회귀 테스트 | `/home/lsjtop10/projects/cornermon/.worktrees/issue-193/frontend/test/admin/features/**` **(기존 파일 확장)** |

## 4. 검증 체크리스트

- [x] feature controller가 file_saver 구체 구현이 아니라 shared Provider 포트만 사용한다.
- [x] PDF는 `pdf`, `MimeType.pdf`, XLSX는 `xlsx`, `MimeType.microsoftExcel`을 전달한다.
- [x] 저장 취소(null)는 error state와 오류 SnackBar를 만들지 않는다.
- [x] 공유 선택은 기존 `Printing.sharePdf`/`SharePlus` 시트를 계속 사용한다.
- [x] 기존 이미지 `cornermon-flutter:3.44.7`로 관련 테스트와 정적 분석을 실행하며 새 이미지를 pull하지 않는다.
- [x] `flutter analyze lib` 통과, #193 관련 controller·widget 테스트 32건 통과.
- [ ] 전체 `flutter test`는 #193 범위 밖 기존 실패 5건으로 통과하지 못함(변경하지 않음).
