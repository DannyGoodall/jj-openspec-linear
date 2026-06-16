---
name: change-context
description: >-
  Redirect the conversation's working context to the jj WORKSPACE that holds a
  change (proposal/tasks/code) that does NOT exist in the base checkout. Given an
  issue reference (e.g. <ID>) or a change slug (e.g. lane-stacking), it resolves
  the workspace dir (../<slug>), verifies it, loads the change's
  proposal/tasks/design (or, code-only, the issue body), and states a working
  contract — cwd = the workspace for every CLI/test/dev command, all workspace
  file ops via native Read/Edit/Write/Grep/Glob on absolute ../<slug>/ paths,
  Serena reserved for base-checkout work — so the agent operates there for the
  rest of the session. Use at the START of a conversation, in the same agent (no
  second instance), to "focus on workspace X" without re-explaining it each turn.
  Triggers: "/change-context <ID>", "focus on the workspace for <slug>", "work in
  the jj workspace called X". It only SETS context — it does not implement, push,
  or open a PR (that's make-change / end-change). The issue tracker is pluggable.
---

# Change Context

The context-entry primitive for the change workflow. A change created by `start-change` lives
**only** in a sibling jj workspace (`../<slug>`); a base-rooted agent can't see it and would
mis-target edits. This skill points the conversation at that workspace and loads its context, so
all subsequent work — yours or `make-change`'s — lands in the right place. It is the shared "enter
the workspace" step `make-change` composes; on its own it's how a fresh agent adopts a workspace
for an open-ended session (debugging, review, iterating, re-testing). It delegates jj mechanics to
the `jj-vcs:jj` skill (HARD prereq). It only SETS context — no implement, push, or PR.

## Workflow

### 1 — Resolve the workspace
The argument is either an **issue reference** or a **slug**:

- **Issue reference** (`<ID>`): resolve the issue-tracking binding, read the issue + its
  `start-change` / `end-change` cross-link comment, and derive the sibling `../<slug>` it records
  (see `references/resolving-and-contract.md` + `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md`).
- **Slug**: the workspace is the sibling `../<slug>` directly — no tracker lookup needed.

### 2 — Verify (before adopting)
- `../<slug>` exists and `jj workspace root` (run there) ends in `<slug>`.
- If it carries an OpenSpec change: `cd ../<slug> && openspec list` shows `<slug>`.
- If verification fails, **stop and report** — don't state a contract. The workspace may not exist
  yet (run `start-change` first).

### 3 — Load the change context
Read what's in the workspace so the agent actually knows the change:
- **OpenSpec change** → `openspec/changes/<slug>/proposal.md`, `tasks.md` (report tasks done/total),
  `design.md` (if present), and the delta `specs/`.
- **Code-only change** → the issue body + the workspace's working-copy commit description.

State a one-paragraph summary: what the change is, OpenSpec or not, where it stands.

### 4 — State the working contract (it governs the rest of the session)
Declare explicitly and hold until the conversation ends or the user redirects:
- **cwd:** every `openspec` / test / dev command runs with `../<slug>` as cwd
  (`cd ../<slug> && …`); the shell resets between calls, so set it each time.
- **file ops:** all reads/edits via native **Read / Edit / Write on absolute paths under
  `../<slug>/`**, with `Grep` / `Glob` to navigate. These always hit the workspace.
- **Serena:** **not used for workspace files** — reserved for normal base-checkout work. Its active
  project is the base checkout and can't be re-pointed (`claude-code` excludes `activate_project`),
  so its *edit* tools would silently corrupt the base and its *reads* of files you've edited go
  stale. Stay single-agent — no second `claude` launched in the workspace.
- **bookmark:** note `<type>/<slug>`; no push here.

Establish where work happens, then yield. (For a human working in a terminal, `cw <slug>` enters
the workspace and `cw <slug> --hydrate` carries gitignored essentials across — see
`${CLAUDE_PLUGIN_ROOT}/references/cw-helper.md`.)

## Principles

- **Sets context only.** No implement, push, or PR — that's `make-change` / `end-change`.
- **Verify before adopting.** Confirm the workspace really carries the change first; never operate
  against an unverified or base checkout.
- **Re-state the contract.** It's a durable instruction the rest of the conversation honours — cwd,
  absolute-path native edits, Serena reserved for base.
- **Serena reads base, never writes here.** The wrong-checkout edit trap is the central risk;
  absolute-path Read/Edit/Write on `../<slug>/` is the safe channel.
- **Tracker is pluggable.** Resolve the binding for an issue argument; a slug argument needs none.

## Bundled resources

- `references/resolving-and-contract.md` — issue → workspace resolution detail and the full
  working-contract checklist `make-change` (and any in-workspace work) relies on.
- `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` — pluggable issue-tracking binding (mode
  selection, per-mode operations) used to resolve an issue argument to its slug.
- `${CLAUDE_PLUGIN_ROOT}/references/cw-helper.md` — the `cw` shell helper a human uses to enter
  and hydrate the workspace in a terminal.
