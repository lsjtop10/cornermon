# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Part-specific implementation patterns (commands, layer structure, known pitfalls) live in
each part's developer guide — **read the relevant one before working there**:
- `backend/docs/DEVELOPER_GUIDE.md`
- `frontend/docs/DEVELOPER_GUIDE.md`

## Workflow Rules

**Before starting any task**, read the relevant files in `./workflow/`:
- `workflow/implement.md` — implementation constraints
- `workflow/plan.md` — plan document format and guidelines
- `workflow/Collaborate.md` — API change protocol
- `workflow/pr.md` — PR/commit conventions
- `workflow/repo.md` — monorepo management rules

**After finishing**, verify nothing violates the workflow guidelines.

**New worktrees**: Always confirm with the user before creating a new worktree.

---

## Monorepo Structure

```
/api/               # OpenAPI 3.0 contract (source of truth for REST API)
/backend/           # Go backend (see backend/docs/DEVELOPER_GUIDE.md)
/frontend/          # Flutter app, two entry points: lib/main_admin.dart, lib/main_facilitator.dart
                     # (see frontend/docs/DEVELOPER_GUIDE.md)
/docs/               # Domain model, technical design, screen specs
/workflow/          # Process guidelines (must read before working)
```

---

## Global Architecture Principles

These constrain the contract between frontend and backend and are non-negotiable regardless
of which part you're working in. Implementation detail for each lives in the respective
developer guide.

- **Layered dependency direction** (backend): `domain` imports nothing external; `usecase`
  declares ports (interfaces); `adapter`/`infrastructure` implements them and is injected at
  startup. Business invariants live on domain methods, not the usecase layer.
- **Authentication**: all tokens (facilitator track PIN sessions, device trust tokens, admin
  access/refresh) are **opaque tokens**, not JWT, stored as hashes. This is a finalized
  decision — do not propose JWT.
- **SSE real-time push**: broadcast only after commit (rolled-back changes must never reach
  clients); events carry full snapshots, never deltas; clients treat reconnect as resync.
- **API Change Protocol**: per `workflow/Collaborate.md`, frontend opens a PR first, then
  backend implements and **must update `api/openapi.yaml`** before merging.

---

## Key Domain Concepts (Ubiquitous Language)

| Term | Go type / constant |
|---|---|
| Camp (캠프) | `domain.Camp`, states: `CampPending/Active/Ended` |
| Group (조) | `domain.Group`, status derived from `Itinerary` |
| Corner (코너) | `domain.CornerID` (struct TBD) |
| Track (트랙) | per `domain-model.md §2.2`, states: ACTIVE·IDLE / ACTIVE·BUSY / DELETED |
| Visit (방문) | per-corner status on `Group.Itinerary`: `VisitNotVisited/InProgress/Completed` |
| Badge (배지) | `domain.Badge`, states: UNASSIGNED / ASSIGNED |
| Itinerary (순회표) | `[]domain.CornerProgress` on `Group` |

Naming in code must map 1:1 to these ubiquitous language terms (`workflow/implement.md`).

---

## Planning

Plans go in:
- `docs/artifacts/plan/` — cross-cutting work
- `backend/docs/artifacts/plan/` — backend-only work
- `frontend/docs/artifacts/plan/` — frontend-only work

Filename format: `[작업요약]_plan_[YYYYMMDD].md`

Plans must lead with use cases (P0/P1/P2), include object definitions + method signatures (not implementation bodies), and end with a verification checklist. See `workflow/plan.md` for the full template.

## scope of work

사용자가 명시하지 않는 이상 백엔드 작업은 백엔드 폴더만 프론트엔드 작업은 프론트엔드 폴더만 수정합니다.

## 보고 필수

작업을 시작하기 전 혹은 중간 과정을 사용자에게 간단히 브리핑합니다.
