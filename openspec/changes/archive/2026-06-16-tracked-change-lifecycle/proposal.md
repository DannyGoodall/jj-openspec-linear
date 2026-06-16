# tracked-change-lifecycle

## Why

A tracked code change in this repo passes through distinct, human-paced phases — understand it, set it up, enter its workspace, implement it, ship it, and tear it down. Today that discipline lives in a loose family of skills that each re-explain the same mechanics (jj workspaces, the `<type>/<slug>` naming triple, the Serena-wrong-checkout trap, ship-not-merge). The behaviour is proven but un-specified: nothing pins down the guards that keep the lifecycle safe (an unverified workspace must not be implemented in, an unmerged change must not be torn down, a bookmark must only be moved from the primary workspace). This change captures that lifecycle as requirements so the `change-lifecycle` plugin packages one coherent, tracked, human-paced contract rather than a bag of overlapping skills.

## What Changes

- Specify the **change lifecycle** — `start-change` (setup), `make-change` (implement), `end-change` (ship), `teardown-change` (destructive cleanup) — including the slug-coordination rule (one kebab-case slug names workspace dir, bookmark, and OpenSpec change-id) and the ship-not-merge rule (changes land as reviewed PRs, never self-merged).
- Specify the **workspace context** primitive — `change-context` — that resolves a change's jj workspace from an issue or slug, verifies it before adopting it, loads the change context, and states + holds the working contract (cwd, native file ops, Serena reserved for base-checkout).
- Specify **change triage** — `triage-change` — that reads one issue plus its governing specs and code, produces a determination, runs the OpenSpec gate honestly, decides a triage label, short-circuits on missing information, and is idempotent on re-triage.
- These capabilities refer to "the issue tracker" abstractly; the concrete tracker binding (Linear MCP vs `gh` Issues) is owned by the separate `optional-issue-tracker-binding` change (capability `issue-tracking`).

## Capabilities

### New Capabilities

- `change-lifecycle` — the setup → implement → ship → teardown phases for a tracked change, with slug coordination and ship-not-merge guards.
- `workspace-context` — the `change-context` primitive that resolves, verifies, loads, and holds a workspace working contract.
- `change-triage` — the `triage-change` determination, OpenSpec gate, labelling, and idempotency.

### Modified Capabilities

_None._

## Impact

- Adds three OpenSpec capability specs under `openspec/specs/` once archived.
- Defines the behavioural contract for the `change-lifecycle` plugin's skills (`start-change`, `make-change`, `end-change`, `teardown-change`, `change-context`, `triage-change`).
- Depends on the `jj-vcs` plugin (`jj-vcs:jj` skill) for all jj mechanics and on the `issue-tracking` binding (separate change) for concrete issue-tracker operations.
- No runtime code in this change — artifacts only.
