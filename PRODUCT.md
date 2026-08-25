# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

**Note:** two native Flutter apps share one non-OS-adaptive custom design system (`docs/design-system.md`) — there is no Cupertino/Material branching by platform. Admin is iPad-only (landscape-first). Facilitator ships on both iOS and Android phones (portrait-first) but with the *same* design language on both — Android is a build target, not a design fork. Treat `ios` as the reference platform; adapt work must still verify the facilitator app on both iOS and Android phone sizes, not native per-OS idiom.

## Users

- **관리자 (Admin)** — up to 2, fully equal permission, working from a stationary iPad at the event venue. Glances at the dashboard while doing other things; needs to spot problems (bottlenecks, device requests, stalled corners) at a glance, then intervene (change target times, approve devices, message tracks, replace tracks).
- **진행자 (Facilitator)** — staff assigned to one track (a corner's processing unit), using a phone one-handed while actively greeting groups. Job: scan a group's QR badge in, confirm exit, occasionally handle manual check-in when a badge can't be scanned. Speed and short tap paths matter more than information density.
- **조장 (Group Leader)** — a student representing their group; carries a printed QR badge, installs no app, and is a passive scan target only.

## Product Purpose

Operates a single-event "corner learning" program (코너학습): a fixed roster of ~20 groups rotates through ~10 fixed-location learning corners over the course of one camp. The system tracks each group's per-corner visit lifecycle (not-visited → in-progress → completed), lets admins monitor load and intervene in real time (target-time overrides, track replacement, device trust, messaging), and produces a post-camp report once the camp ends. Success = every group's itinerary accurately reflects real-world progress with minimal friction at the point of scanning, and admins can see and unblock bottlenecks before they cascade.

## Positioning

Not a general event-check-in tool: the domain model is built specifically around track-scoped PIN authentication (no facilitator accounts), a hard 1-active-visit-per-track constraint, and a "notify-then-refetch" SSE model chosen because exact real-time delivery isn't required — competitors doing generic RSVP/badge-scanning don't share this specific operational shape (single-event, camp state machine PENDING→ACTIVE→ENDED, no idle-timeout on facilitator sessions because the venue-side risk of re-authentication interrupting a scan outweighs the security cost).

## Operating Context

- Runs once per "camp" (single real-world event, hours-long), not a persistent multi-tenant SaaS.
- Admin device: iPad, mounted/stationary, ambient monitoring ("scan," not "read") — color+icon first, text secondary.
- Facilitator device: phone, one-handed, outdoors possible, urgency — large buttons, ideally ≤2 taps, easy to undo mistakes.
- Physical artifacts in the loop: printed QR badges (reusable across camps), printed PIN cards for facilitator login.
- Both apps support light and dark mode as a baseline requirement, not an extra (always-on tablet screens, possible dim venues).
- Friction is treated as a bigger risk than errors: re-auth/delay must not block an urgent scan; confirmation modals default to "warn then allow" except where the domain explicitly hard-blocks (e.g. deleting a track with an in-progress visit).

## Capabilities and Constraints

- Camp lifecycle: PENDING (setup only, no facilitator login) → ACTIVE (full real-time operation) → ENDED (report-only, no writes), admin-driven, one-way, no reversal.
- A group can be `IN_PROGRESS` at only one corner/track at a time; a corner cannot be completed twice by the same group (duplicate-visit block).
- A track belongs to exactly one corner permanently; deleting a track with an in-progress visit is hard-blocked; deleting the last active track on a corner is allowed with a warning (corner going idle is normal).
- Facilitator auth is a 6-digit track PIN, no personal account; sessions never expire from idle timeout — only admin force-logout, track deletion, camp end, or PIN regeneration end a session, and this happens immediately even mid-visit.
- Device trust: an unregistered device cannot reach the PIN screen; camp registration uses an out-of-band 8-char registration code (not the raw camp ID, for security reasons — see domain model §2.4-b), and devices go through PENDING → APPROVED/REJECTED, revocable to REVOKED.
- Bottleneck detection is a per-camp configurable ratio + minimum-sample threshold (`bottleneckRatio`, `minSamples`) evaluated live, not a hardcoded duration.
- Queueing is explicitly out of scope: the system does not model or store wait order in front of a corner.
- Auth tokens across the whole system (facilitator PIN sessions, device trust tokens, admin sessions) are opaque, not JWT — this is a finalized architectural decision.
- Real-time updates are lightweight SSE change notifications, not snapshots; clients REST-resync on ordinary events (except `camp_ended`, a terminal exception where facilitator clients clear credentials locally without a REST round-trip).
- Full domain vocabulary and state machines are canonical in `docs/domain-model.md` — treat as source of truth, not to be restated informally elsewhere.

## Brand Commitments

The current palette, type scale, and component language in `docs/design-system.md` are the **confirmed** visual identity, not a placeholder awaiting a future camp brand. (`design-system.md` §1.1 still carries an older "placeholder — swap for real camp brand" note; that note is stale as of this decision and should be updated/removed the next time that file is touched, per doctor's normal drift-repair flow — not rewritten as a side effect of this file.)

- Product name in Korean: 코너학습 (Corner Learning). Two shipped apps are distinguished to end users as "코너학습 관리자" (Admin) and "코너학습 진행자" (Facilitator).
- Status color vocabulary (IDLE / BUSY / DEVIATION+ / NO_TRACK) is a fixed semantic system tied 1:1 to domain state — future work must not repurpose these four meanings.
- Design voice: operational tool, not a marketing surface — "glanceable" and "quiet unless something's wrong" outrank decorative expression (see `docs/design-system.md` §0).

## Evidence on Hand

No real screenshots, live camp data, or named client organization exist yet beyond the specification documents (`docs/domain-model.md`, `docs/design-system.md`, `docs/front/screen-spec-admin.md`, `docs/front/screen-spec-facilitator.md`, `docs/technical-design.md`) and the current Flutter implementation under `frontend/lib/`. Future work must not fabricate testimonials, a client/organization name, or sample camp content — use clearly-marked placeholder data (e.g. "1조", "2조", generic corner names already used in the specs) instead.

## Product Principles

1. **Glance over read.** Both apps are used while the operator is doing something else (monitoring ambiently, greeting a group) — status must be legible from color+icon alone, with text as confirmation, not the primary channel.
2. **Friction is the enemy, not error.** Default to "warn and allow" over hard blocks; the exceptions are the few domain invariants explicitly marked hard-blocks (in-progress-visit track deletion, duplicate visit completion).
3. **Quiet by default, loud only when wrong.** Steady-state indicators (connected, normal) are omitted entirely; only abnormal states (reconnecting, bottleneck, disconnected) earn screen space.
4. **One shared domain, two disjoint apps.** Admin and Facilitator never import each other's screens/widgets; anything genuinely shared is promoted to `/common` first. Don't blur this boundary when designing new screens.
5. **The venue outranks the office.** Design decisions resolve in favor of the person standing at a corner with a phone and a queue of students, not the person configuring the system beforehand.

## Accessibility & Inclusion

- Corner/track status must be distinguishable without color alone (colorblind users, several meters' viewing distance outdoors) — color is always paired with icon/shape, never the sole channel.
- All four state colors must meet WCAG AA (4.5:1) text contrast in both light and dark mode.
- Touch targets: 44×44pt minimum (admin/iPad, Apple HIG), 48×48dp minimum on facilitator (56dp+ for the primary scan/end action).
