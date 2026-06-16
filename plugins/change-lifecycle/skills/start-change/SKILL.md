---
name: start-change
description: >-
  Kick off a tracked code change on jj workspaces: create the tracking issue,
  spin up a dedicated jj workspace for it, and — only when the change touches
  OpenSpec specs — author the proposal via the OpenSpec propose skill. One slug
  names the workspace (../<slug>), the bookmark (<type>/<slug>), and the
  OpenSpec change-id, so everything (including the eventual PR) stays
  coordinated. Use when the user wants to "start a change", "open/spin up a
  workspace for this", or "kick off a change/feature/bugfix" before
  implementing. Setup only — stops once the issue, workspace, and (if needed)
  approved proposal exist; does NOT implement and does NOT open the PR. The
  issue tracker is pluggable (Linear, GitHub Issues, or none).
---

# Start Change

Stand up the scaffolding for a code change so work is tracked and isolated before any
code is written: a **tracking issue**, a dedicated **jj workspace**, and — conditionally
— an **OpenSpec proposal**. This skill owns *kickoff naming*. It delegates jj mechanics to
the `jj-vcs:jj` skill (HARD prereq), issue ops to the issue-tracking binding, and proposal
authoring to the OpenSpec propose skill. It does **not** implement and does **not** open a PR.

## One slug — decide once, reuse everywhere

Everything keys off a single kebab-case **slug** (`grey-hues`, `bump-max-pupils`) plus a
**type** in conventional-commit style (`fix`, `feat`, `chore`). Don't repeat the type inside
the slug (`fix/grey-hues`, not `fix/fix-grey-hues`):

| Artifact          | Value           | Example                |
|-------------------|-----------------|------------------------|
| jj workspace dir  | `../<slug>`     | `../bump-max-pupils`   |
| jj bookmark       | `<type>/<slug>` | `feat/bump-max-pupils` |
| OpenSpec change-id| `<slug>`        | `bump-max-pupils`      |

One slug lets the PR, branch, and change folder all visibly concern one thing. No later
phase mints a second slug — implement and ship reuse this one. See
`references/jj-workspace-and-naming.md` for the naming rules and pitfalls.

## Workflow

### 1 — Type / slug / OpenSpec gate (consume triage, or run it here)

The type/slug/OpenSpec call is owned by the `triage-change` skill. If the issue already
carries a determination (a `ready-for-agent` label + determination comment), **consume it**
— take its `type`, `slug`, `openspec` verdict, and fix-sketch. Otherwise run `triage-change`
first, or — for a direct run with no prior determination — gate honestly here:

- **Type** → `fix` (repair broken/unintended behaviour), `feat` (new capability), else `chore`.
- **Slug** → short kebab-case name from the request; don't repeat the type in it.
- **OpenSpec needed?** Apply the gate below.

**The gate — one question:** *after this change, would any OpenSpec spec or `design.md`
have to change to reflect the new reality?*

- **No → skip OpenSpec.** Every requirement under `openspec/specs/` and every `design.md`
  stays accurate — a genuine bug fix restoring intended behaviour, a typo, a CSS hue, an
  off-by-one, dead-code removal.
- **Yes → drive through OpenSpec.** The change adds/alters/removes a functional or design
  requirement, touches the data model / migration / API / auth, or introduces a capability —
  anything that makes the current specs stale. **When in doubt, propose** — the proposal is
  the cheapest, reviewable place to catch misalignment before code exists.

### 2 — Create (or reuse) the tracking issue

Resolve the issue-tracking binding first and **state which mode** you are in (see
`${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md`):

- **Linear mode** / **GitHub mode** — **search first** to avoid duplicates, then create the
  issue with an action-oriented title and a body covering context / intended change /
  acceptance criteria. Apply the categorical + triage label/status for the active mode (see
  `${CLAUDE_PLUGIN_ROOT}/references/triage-labels.md`). Capture the `<ID>` and URL.
- **No-tracker mode** — record the slug and workspace path and proceed; say explicitly that
  no issue was created. The change is still tracked by its OpenSpec folder, the jj bookmark,
  and the eventual PR.

### 3 — Create the jj workspace + reserve the bookmark

From a clean working copy, create the workspace based on `main` and reserve its bookmark.
Defer exact flags/revsets to the `jj-vcs:jj` skill; the shape is:

```bash
jj workspace add --name <slug> --revision main ../<slug>
jj bookmark create <type>/<slug> --revision @ -R ../<slug>
```

Give the workspace's first commit a description that names the issue (`Refs <ID>`) so the
issue is discoverable from the commit and later the PR. **Idempotent:** if `../<slug>`
already exists, reuse it — check `jj workspace list` before creating.

### 4 — (OpenSpec gate true only) Author + approve the proposal

Hand authoring to the OpenSpec **propose** skill (`/openspec-propose` or `opsx:propose`),
passing the **slug as change-id** so it scaffolds `openspec/changes/<slug>/`. Run it
**inside the new workspace** so the proposal travels with the change. Record the `<ID>` in
`proposal.md`, and note the change-id + `openspec/changes/<slug>/` path on the issue. Then
**wait for approval** (the user / OpenSpec's review gate) — do not start implementation.
Skip this whole step when the gate is false.

### 5 — Cross-link and stop

Cross-link the issue and the workspace via the binding: comment on the issue with the
workspace path + bookmark (+ change-id if any). Confirm the three artifacts line up under
one slug, then **stop**. Report: issue `<ID>` (or "no-tracker"), workspace path, bookmark,
and — if OpenSpec — proposal status. Implementation and PR are out of scope: the user
implements with `make-change`, then `end-change` ships the PR.

## Principles

- **Setup only.** Issue + workspace + (maybe) approved proposal. No code, no PR. Hand off cleanly.
- **One slug, everywhere.** Workspace, bookmark, and change-id share it, so downstream PR
  linkage is automatic, not narrated.
- **Tracker is pluggable.** Linear OR GitHub Issues OR none — resolve the binding at runtime
  and never hard-require Linear; in no-tracker mode, record the slug and proceed.
- **Idempotent.** Reuse an existing issue/workspace/proposal rather than duplicating.

## Bundled resources

- `references/jj-workspace-and-naming.md` — slug/type naming rules, `jj workspace add`/bookmark
  mechanics, and how the bookmark feeds the eventual PR. Read when creating the workspace.
- `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` — pluggable issue-tracking binding
  (mode selection, per-mode operations, issue↔PR linkage).
- `${CLAUDE_PLUGIN_ROOT}/references/triage-labels.md` — canonical triage roles → per-tracker mechanisms.
