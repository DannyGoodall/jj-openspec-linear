---
name: teardown-change
description: >-
  Tear down a shipped change's jj workspace, bookmark, and working directory once its PR has merged, so
  workspaces don't accumulate. Takes an issue id (e.g. <ID>) or a change slug. DESTRUCTIVE — before
  removing anything it runs a safety assessment (PR merged? bookmark pushed and current? uncommitted or
  untracked files that would be lost?) then a MANDATORY multiple-choice confirmation gate. Use AFTER
  end-change + merge, when the user says "tear down <X>", "clean up the workspace for <ID>", "remove the
  <slug> workspace", or wants to prune a finished change. Removes only — it does not start the next
  change (that's start-change) and does not merge anything.
---

# Teardown Change

The cleanup bookend of the change workflow: `… → end-change → (merge) → **teardown-change** → start-change`
the next one. Once a change's PR is merged, its sibling jj workspace (`../<slug>`), bookmark
(`<type>/<slug>`), and on-disk directory are dead weight — this removes them, safely and on purpose.

Delegate all jj mechanics to the **`jj-vcs:jj`** skill. This plugin hard-requires the `jj-vcs` plugin.

## Destructive — what is actually recoverable

Be precise about blast radius so the gate is honest:

- **Commits are recoverable.** `jj workspace forget` + deleting the bookmark do **not** destroy commits —
  jj keeps them in the op log; `jj op log` / the change-id can restore them. So *committed* work survives.
- **The directory's UNTRACKED files are NOT recoverable.** `rm -rf ../<slug>` destroys anything not in jj
  and not on the remote: a hydrated `.env.local`, `node_modules` (both regenerable), **and any ad-hoc
  untracked file the user created there** (not regenerable). This is the real irreversible loss.
- **Unpushed commits survive in the store but lose their working tree.** If the bookmark was never pushed,
  the commit lives on via the op log, but its checked-out directory is gone after `rm -rf`.

## Procedure

### 0 — Resolve the target

From an issue id or a slug, resolve the workspace `../<slug>` and bookmark `<type>/<slug>` (the same
resolution `change-context` uses). For an issue, resolve the issue→change binding per
`${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` and read the 🤖 start/end-change cross-link comment
to recover the slug. Confirm the workspace exists; if it doesn't, say so and stop (nothing to tear down).

### 1 — Safety assessment (gather the facts the gate will show)

- **Merged?** `gh pr view <type>/<slug> --json state,mergedAt` (or check the bookmark commit is an
  ancestor of `main@origin`). Merged → safe.
- **Pushed & current?** Is `<type>/<slug>` pushed and equal to its remote-tracking bookmark? Unpushed
  commits → unsafe.
- **Working-tree state?** In `../<slug>`, `jj st` for uncommitted changes; list **untracked** files
  beyond the standard `.env.local` / `node_modules` (those are the irrecoverable ones).

See `references/safety-and-recovery.md` for the exact commands.

### 2 — GATE (mandatory — never skip)

Present a **single-select multiple-choice question** (AskUserQuestion) summarising the assessment and
recoverability. **Do not run any destructive command until the user picks an affirmative option.**
Recommend the safe answer based on the assessment. Shape it like:

> **Tear down `../<slug>` (<ID>)?** Forgets the jj workspace, deletes bookmark `<type>/<slug>`, and
> `rm -rf`s the directory. PR is **<merged|NOT merged>**; bookmark **<pushed|unpushed>**; **<N> untracked
> file(s)** in the dir (`.env.local`, `node_modules`, …) will be **permanently lost** (commits recoverable
> via `jj op log`; untracked files not). This cannot be undone.

- Merged + clean → options: **"Yes — tear down (Recommended)"** / "No — keep it".
- Not merged / unpushed / has non-standard untracked files → recommend **"No — keep it"** and offer a
  distinct **"Force teardown"** option that names the loss explicitly. Never fold "force" into the safe
  yes.

### 3 — Remove (only after an affirmative choice)

Run from the **primary** workspace (you can't forget the workspace you're standing in):

```bash
cd <primary>                       # e.g. the repo root
jj workspace forget <slug>         # detach the workspace
rm -rf ../<slug>                   # remove the working directory
jj bookmark delete <type>/<slug>   # local bookmark (remote branch usually gone on merge)
jj workspace list                  # confirm <slug> is gone
```

### 4 — Report

State what was removed and the recovery path for committed work (`jj op log` → change-id / op hash) in
case of regret. Then stop. (Starting the next change is `start-change`, not this skill.)

## Principles

- **Gate, always.** No destructive command runs before the multiple-choice confirmation — even when
  merged and clean.
- **Be honest about recoverability.** Commits return via the op log; the directory's untracked files are
  gone. Surface unmerged / unpushed / untracked work loudly and make "force" a distinct choice.
- **Remove only.** No merge, no next-change. Teardown is a single, well-scoped, recoverable-where-possible
  cleanup.
- **From the primary.** Run `jj workspace`/`bookmark` ops from the primary checkout; you can't forget the
  workspace you're standing in.

## Bundled resources

- `references/safety-and-recovery.md` — merged/pushed/untracked assessment commands, the exact teardown
  sequence, and how to recover a torn-down change from `jj op log`.
- `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` — issue-tracking binding (Linear → GitHub → none),
  used to resolve the slug from an issue id.
