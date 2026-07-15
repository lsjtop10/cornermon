# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow Rules

**Before starting any task**, read the relevant files in `./workflow/`:
- `workflow/implement.md` — implementation constraints
- `workflow/plan.md` — plan document format and guidelines
- `workflow/Collaborate.md` — API change protocol
- `workflow/repo.md` — monorepo management rules

**After finishing**, verify nothing violates the workflow guidelines.

**New worktrees**: Always confirm with the user before creating a new worktree.

---

## Commands

### Backend (Go)

```bash
cd backend

# Run all tests
go test ./...

# Run tests for a single package
go test ./internal/domain/...

# Run a single test
go test ./internal/domain/... -run TestCampActivate

# Run the server
go run ./cmd/server/main.go

# Format
gofmt -w .

# Vet
go vet ./...
```

No Makefile exists yet — `make gen`, `make dev-server`, `make dev-app` are planned but not implemented.

---

## Architecture

### Monorepo Structure

```
/api/               # OpenAPI 3.0 contract (source of truth for REST API)
/backend/           # Go backend
/docs/              # Domain model, technical design, screen specs
/workflow/          # Process guidelines (must read before working)
```

The frontend (Flutter) directory is not yet created. Per `docs/technical-design.md §0-d`, it will use a single Flutter project with two entry points (`lib/main_admin.dart`, `lib/main_facilitator.dart`).

### Backend Package Layout

```
backend/
  cmd/server/main.go
  internal/
    domain/         # Pure Go structs + business rules. NO external imports.
    usecase/        # Application services. Defines ports (interfaces) here.
    adapter/
      postgres/     # Repository implementations
      http/         # REST handlers
      sse/          # SSE broadcaster (Broadcaster interface impl)
```

**Two non-negotiable architecture rules** (`docs/technical-design.md §1.1`):
1. `domain` package imports nothing external — pure Go types and methods only.
2. Dependency inversion: `domain`/`usecase` declare interfaces; `adapter` provides implementations injected at startup.

### Domain Layer Pattern

Business invariants are enforced by domain methods, not the usecase layer. The usecase layer owns transaction boundaries and persistence orchestration.

```go
// Business rule enforcement lives on the struct method
func (t *Track) StartVisit(group GroupID, now time.Time, method InputMethod) (*Visit, error)

// Usecase owns: begin tx → call domain method → persist → commit → broadcast
```

All domain sentinel errors are in `backend/internal/domain/errors.go`. Use `errors.Is()` for error checking — do not add string-matching error checks.

### SSE Real-time Push

- State changes → `usecase` emits domain event → `adapter/sse.Broadcaster` pushes to connected clients.
- **Broadcast only after commit** — never before. Rolled-back changes must never reach clients.
- Events carry full snapshots (not deltas). On (re)connect, server immediately sends current full state.
- Clients handle reconnect = resync. Server does stateless broadcast only.

### Authentication

All tokens (facilitator track PIN sessions, device trust tokens, admin access/refresh tokens) are **opaque tokens** (not JWT). Stored as hashes in DB. This is a finalized decision — do not propose JWT.

### API Change Protocol

Per `workflow/Collaborate.md`: frontend opens a PR first, then backend implements and **must update `api/openapi.yaml`** before merging.

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
