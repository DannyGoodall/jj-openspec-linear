---
name: make-change
description: >-
  Implement a change whose OpenSpec proposal and tasks live in a downstream jj WORKSPACE
  (created by start-change), not the base checkout. Before touching anything it points the
  tooling at the workspace — cwd for the CLI/tests, Claude Code's native Read/Edit/Write for
  all workspace file ops — because a base-rooted agent cannot see the change (`openspec`
  resolves by cwd) and, worse, Serena would SILENTLY edit the wrong checkout (its project stays
  on base; `claude-code` excludes activate_project). Then it delegates apply mechanics to the
  OpenSpec apply skill, implements tasks.md, and verifies. Use when the user says "make /
  implement / apply the change", "do <ID>", or wants to work through the tasks of a change
  start-change set up in a workspace — the implement step between start-change and end-change.
  It does NOT push or open the PR (that's end-change) and does NOT re-derive the design
  (that's start-change).
---

# Make Change

The implement step of the lifecycle: `triage-change → start-change → **make-change** → end-change → teardown-change`.
`start-change` left a jj workspace at `../<slug>` holding the change's OpenSpec proposal +
`tasks.md`. This skill implements those tasks **inside the workspace**, then hands to
`end-change`. It wraps the OpenSpec apply skill — it does not re-implement OpenSpec; it adds the
workspace-targeting the apply skill assumes is already arranged.

Prereq: the `jj-vcs` plugin — delegate all jj mechanics to `jj-vcs:jj`.

## Why this skill exists (the trap it prevents)

The agent runs with cwd = the **base** checkout, but the change exists **only** in the
workspace's `openspec/changes/<slug>/`. Two consequences:

- `openspec` / `bun` / tests run from base **fail loudly** ("change not found") — safe but blocking.
- **Serena fails SILENTLY**: its active project stays on the base checkout and `claude-code`
  excludes `activate_project`, so its *edit* tools would corrupt base `src/` while looking fine.

So the discipline is: **point every tool at the workspace, verify it, then implement.**

## Workflow

### 0 — Target the workspace (run `change-context`)
Run **`change-context <slug-or-issue>`** first — it owns targeting. It resolves and verifies the
workspace, loads the change's proposal/tasks, and establishes the working contract everything
below operates under:
- **cwd:** every `openspec` / `bun` / test command runs with `../<slug>` as cwd (`cd ../<slug> && …`).
- **file ops:** all reads/edits via Claude Code's native **Read/Edit/Write on absolute `../<slug>/`
  paths**; `Grep`/`Glob` to navigate.
- **Serena:** **not used for workspace files** (reserved for base-checkout work). Its active
  project is base and `claude-code` excludes `activate_project`, so its *edit* tools would corrupt
  base — the silent wrong-checkout bug this skill exists to prevent. Single-agent: no second
  agent in the workspace.

If the workspace doesn't verify, **stop** — `start-change` hasn't set it up.

### 1 — Implement (delegate to the OpenSpec apply skill)
Hand the apply mechanics to the **OpenSpec apply skill**, operating against the workspace: read
`proposal.md` / `design.md` / `specs/` / `tasks.md`, implement each task, and tick `tasks.md` as
you go. Do all file work with the native tools on absolute `../<slug>/` paths. Honour the
change's test requirement — write the tests `tasks.md` calls for.

### 2 — Verify
- `cd ../<slug> && openspec validate <slug> --strict` — must pass.
- Run the **targeted** tests the change adds if quick; otherwise note the full suite is deferred to
  the PR per project convention.
- If the workspace doesn't verify, stop and report — don't hand off broken work.

### 3 — Hand off
Stop here. Re-activate Serena on the **base** project before finishing. Hand to `end-change` for
push / PR / archive — **none of that happens here**.

## Principles

- **Target before you touch.** Verify cwd + that Serena is off workspace files before the first
  edit. The silent Serena-wrong-checkout bug is the whole reason this skill exists.
- **Don't reinvent.** Apply mechanics → the OpenSpec apply skill; this skill is the
  workspace-targeting wrapper around it.
- **Stay in lane.** Implement only — no push, no PR, no archive (`end-change`); no redesign
  (`start-change`).
- **Code-only changes too.** If the change has no OpenSpec proposal (e.g. a `chore`), skip the
  apply delegation and just implement the fix in the workspace — the targeting discipline still
  applies.

## Bundled resources

- `references/workspace-retargeting.md` — verify checklist, why Serena stays off workspace files
  (use the native tools), and same-session cwd mechanics.
- `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` — the pluggable issue-tracking binding
  (this skill barely touches it; consult only if you read or update an issue).
