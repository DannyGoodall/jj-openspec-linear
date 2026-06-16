---
name: end-change
description: >-
  Close out a change kicked off with start-change: take the finished work in its jj workspace, push the
  `<type>/<slug>` bookmark to the remote as a branch, open the pull request with `gh`, and wire up
  bidirectional links so the PR records the issue AND the issue records the PR. Archives the OpenSpec
  change first when one exists. Use when the user wants to "end the change", "ship/finish this change",
  "open the PR for this workspace", or "wrap up" a change whose implementation is already done. Does the
  jj→branch→PR handoff and the issue↔PR linkage — it does NOT write implementation code and does NOT
  merge the PR.
---

# End Change

The closing bracket to `start-change`. Implementing the change happens **between** the two skills
(`make-change`). By the time this runs you have a finished jj workspace at `../<slug>`, a reserved
bookmark `<type>/<slug>`, optionally an OpenSpec change `<slug>`, and — if a tracker is in use — an
issue. This skill ships the work as a reviewable PR and makes PR and issue point at each other.

**HARD prereq: the `jj-vcs` plugin.** All jj mechanics (bookmark moves, push, revsets) are delegated to
`jj-vcs:jj`. A jj bookmark *is* a git branch once pushed — there is no conversion step. PRs are a
GitHub concept, so `gh` creates the PR; the issue tracker only links to it.

**Issue tracking is optional and pluggable.** Resolve the binding per
`${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` (Linear mode / GitHub-Issues mode / no-tracker
mode) and state which mode you are in. Generic identifier `<ID>` below.

## The one rule: link both directions, explicitly

The bookmark `<type>/<slug>` does **not** embed the issue identifier, so no integration auto-links it.
Wire both ends yourself (skip this whole concern in no-tracker mode):

- **PR records the issue** → PR body has a closing keyword + the issue reference.
- **Issue records the PR** → the issue gets a comment with the PR URL and moves to its review state.

Both must be true before you stop. Verify, don't assume. Exact per-mode mechanics:
`${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md`.

## Workflow

### 1 — Confirm the work is ready
In `../<slug>`, confirm implementation is complete and the tree is in the intended state (`jj st`,
`jj log`). Do **not** run `bun install` / the test suite — changes ship as PRs tested post-merge. If an
OpenSpec change exists, run `openspec validate <slug> --strict` and treat a failure like a failing test:
fix before shipping.

### 2 — Finalise the commit and the bookmark
Give the change a conventional-commit message that references the issue:

```
<type>(<scope>): <summary>

Refs <ID>
```

Then point the bookmark at the finished commit. **Run bookmark ops from the primary workspace, not from
inside `../<slug>`** — the jj guard blocks bookmark ops inside a worker workspace; reference the
revision explicitly. Defer exact flags to `jj-vcs:jj`.

### 3 — (OpenSpec only) Archive so specs fold in
If a change `<slug>` exists, archive it via the OpenSpec archive skill **on this branch, pre-merge**, so
the PR carries code *and* the updated `openspec/specs/` together and reviewers see them atomically. Skip
entirely for a code-only change with no OpenSpec change.

### 4 — Push the bookmark
From the primary workspace, push the bookmark — it becomes the remote branch of the same name. **This
jj has no `--allow-new`**; the plain push handles the new bookmark:

```bash
jj git push --bookmark <type>/<slug>
```

Idempotent: re-running re-points and re-pushes the existing bookmark without error.

### 5 — Open the PR (PR records the issue)
Check first: `gh pr list --head <type>/<slug>`. If a PR already exists, reuse it (reconcile the body /
links) rather than opening a duplicate. Otherwise create it from the pushed branch, embedding the issue
reference and a closing keyword:

```bash
gh pr create --head <type>/<slug> \
  --title "<summary> (<ID>)" \
  --body "$(cat <<'BODY'
## What & why
<brief problem + solution>
(OpenSpec) Proposal: openspec/changes/<slug>/proposal.md

## Changes
- <code + any spec updates>

## Testing
- <how it was verified / what the reviewer should check>

<issue link line>
Closes <ID>
BODY
)"
```

- **Linear mode**: the closing line is `Closes <ID>` and the issue link is the `url` field returned by
  the Linear MCP (`get_issue`/`save_issue`). **Never hand-build a `linear.app/<workspace>/...` URL.**
- **GitHub-Issues mode**: `Closes #<n>`.
- Use a plain `Refs <ID>` instead of `Closes` only when a partial PR should *not* close the issue.
- **No-tracker mode**: open the PR with a plain description, skip the link line, and say so.

Capture the returned PR URL.

### 6 — Record the PR back into the issue (issue records the PR)
Skip in no-tracker mode. Otherwise, per the binding:

- **Linear mode**: `save_comment` on `<ID>` with the PR URL, and `save_issue` to set
  `state: "In Review"`.
- **GitHub-Issues mode**: `gh issue comment <n>` with the PR URL.

This is the second half of the link — do not skip it assuming an integration handled it.

### 7 — Verify both links, then stop
Confirm the PR body shows `<ID>` + the issue reference, and the issue shows the PR URL (Linear: and
sits in its review state). Report the PR URL, branch, and issue status — then **stop. Do not
self-merge.** Merge only if the user explicitly asks; on this colocated jj repo, judge a merge by the
PR's resulting state (`gh pr view`), not the command's exit code.

## Principles

- **No conversion, just a push.** The reserved bookmark *is* the branch; `jj git push` ships it.
- **Both directions, by hand.** PR→issue via closing keyword + reference; issue→PR via a comment (+
  status in Linear). The branch name carries no identifier, so nothing auto-links.
- **Tracker optional.** Resolve the binding and state the mode; no-tracker mode ships the PR and skips
  the issue half.
- **Code and specs together.** Archive the OpenSpec change in-branch before the PR.
- **Ship, don't merge.** End at a reviewable PR with both links live; leave the merge to a human.
- **Idempotent.** Re-running reuses the pushed branch / open PR — check `gh pr list --head
  <type>/<slug>` before creating a second one.

## Bundled resources

- `references/jj-to-pr-and-linking.md` — the jj-bookmark→git-branch→PR mechanics, the bidirectional
  linking checklist for both tracker modes, and the colocated-jj gotchas (no `--allow-new`, bookmark
  ops from primary, merge-by-state). Read when pushing and opening the PR.
- `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` — the pluggable issue-tracking binding: mode
  selection, per-mode operations, and the bidirectional issue↔PR linkage contract.
