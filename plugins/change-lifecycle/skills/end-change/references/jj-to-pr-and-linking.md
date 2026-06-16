# jj workspace → branch → PR, bidirectional linking

How a finished change in a jj workspace becomes a GitHub PR linked to its issue **in both directions**.
Defer exact jj flags/revsets to `jj-vcs:jj`; this file covers the conventions and colocated-jj gotchas
this skill depends on. For per-mode tracker operations see
`${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md`.

## No "convert jj to git"

This repo is jj backed by git. **A jj bookmark IS a git branch the moment it is pushed.** `start-change`
already reserved `<type>/<slug>`; shipping is just:

```bash
jj git push --bookmark <type>/<slug>
```

That publishes a remote branch named `<type>/<slug>` (e.g. `feat/lane-stacking`). No `git switch`, no
cherry-pick, no rebase onto a git branch.

## Colocated-jj gotchas (learned the hard way)

- **No `--allow-new`.** This jj does not accept `--allow-new`; a plain `jj git push --bookmark <name>`
  pushes a new bookmark fine. Adding the flag errors.
- **Bookmark ops run from the primary workspace.** The jj guard blocks `jj bookmark create/move` when
  the cwd is inside a worker workspace (`../<slug>`). Run bookmark commands from the primary checkout
  and name the revision explicitly (`-r` / `--to`).
- **Judge a merge by PR state, not exit code.** If asked to merge, `gh pr merge` on a colocated jj repo
  can report a nonzero/odd exit while the merge actually succeeded — confirm via `gh pr view` state.

## Why we link by hand (no auto-link)

Linear's GitHub integration auto-links a PR only when the **branch name embeds the issue identifier**
(its `gitBranchName`, e.g. `bletch/eng-123-...`). Our convention is semantic — `<type>/<slug>` — and
carries **no** identifier, so nothing fires automatically. We wire both ends by hand instead.

## Closing keywords vs plain references

The same keyword grammar applies in both tracker modes (Linear's GitHub integration and GitHub Issues
both honour it):

- **Closing keyword** — `Close`/`Closes`/`Fix`/`Fixes`/`Resolve`/`Resolves` + the identifier. Links the
  PR **and** moves the issue to Done/closed when the PR merges. Put it on **its own line** in the PR
  body for maximum reliability.
- **Plain reference** — `Refs <ID>`, `Part of <ID>`, or a bare `<ID>`. Links without closing. Use for
  partial / stacked PRs where this PR should not close the issue.

One PR may reference several issues (keyword per issue it closes); one issue may have several PRs (plain
refs on the intermediate ones, the closing keyword only on the PR that completes the work).

## Bidirectional-linking checklist

Direction 1 — **PR records the issue** (in the PR body):
- **Linear mode**: a `Closes <ID>` line **and** the issue `url` from the Linear MCP
  (`get_issue`/`save_issue`). Never construct a `linear.app/<workspace>/...` URL by hand — the MCP's
  `url` is the canonical one.
- **GitHub-Issues mode**: a `Closes #<n>` line.
- **No-tracker mode**: no issue line; note explicitly that no issue was recorded.

Direction 2 — **issue records the PR**:
- **Linear mode**: `save_comment` on `<ID>` with the PR URL, and `save_issue` `state: "In Review"`.
- **GitHub-Issues mode**: `gh issue comment <n>` with the PR URL (the closing keyword also
  cross-references it).
- **No-tracker mode**: nothing to do.

Then verify:

1. `jj git push --bookmark <type>/<slug>` succeeded; the remote branch exists.
2. PR opened from `<type>/<slug>`; body has the closing keyword + issue reference (Direction 1).
3. Issue has a comment with the PR URL (Linear: and is in its review state) (Direction 2).
4. Opened both artifacts and confirmed each shows the other.
5. Reported PR URL + branch + issue status; **stopped without merging.**
