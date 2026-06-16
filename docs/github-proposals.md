# OpenSpec proposals in the GitHub PR

For an OpenSpec-governed change (`openspec: yes`), the formal proposal does not
live separately from the code — it **travels into the pull request with the code**,
so a reviewer sees the updated specifications and the implementation as one atomic
unit. This doc explains that flow and how the resulting PR records its originating
issue.

For the OpenSpec gate decision itself, see [workflow.md](workflow.md). For the
issue-side linkage details, see [issue-tracker.md](issue-tracker.md).

## The proposal's journey to the PR

The single slug keeps everything coordinated: the OpenSpec change-id, the workspace
directory, and the bookmark all share `<slug>` (see
[workflow.md](workflow.md#slug-coordination)).

1. **Author** — `start-change` authors the proposal in the `../<slug>` workspace
   via the OpenSpec propose skill (only when the gate is `yes`) and waits for
   approval. The proposal lives under the change folder
   (`openspec/changes/<slug>/`).
2. **Implement** — `make-change` implements `tasks.md` in the same workspace,
   delegating apply mechanics to the OpenSpec apply skill, and validates with
   `openspec validate <slug> --strict`. Code and change artifacts now sit together
   in the workspace.
3. **Archive in-branch, pre-merge** — `end-change` **archives the OpenSpec change
   in-branch before the PR merges**, so the archived specs (the change folder's
   spec deltas folded into `openspec/specs/`) land in the **same branch** as the
   code. The PR therefore carries the code change **and** the archived
   specifications **together** — there is no separate "update the specs later"
   step.
4. **Ship** — `end-change` points the bookmark at the finished commit (from the
   primary workspace), pushes it, and opens the PR with `gh`.

Because the archive happens in-branch and pre-merge, merging the PR is a single
decision that lands both the implementation and the specification update at once.

A **code-only** change (`openspec: no`) has no proposal and no archive step — the
PR carries just the code.

## How the PR records the issue

The bookmark `<type>/<slug>` contains no tracker identifier, so the PR↔issue link
is wired **explicitly** by `end-change` when it opens the PR. The exact syntax
depends on the active tracker mode:

| Mode | PR body records | Issue side |
|------|-----------------|-----------|
| Linear | `Closes <ID>` + the issue URL (MCP `url` field) | a comment with the PR URL (`save_comment`); status → `In Review` |
| GitHub | `Closes #<n>` | a comment / cross-reference to the PR |
| none | _no issue to record_ | _tracked by OpenSpec folder + bookmark + PR_ |

`end-change` writes **both directions** and verifies both links before it stops.
It never merges the PR — that is a human decision (see
[workflow.md](workflow.md#why-ship-not-merge)).

## See also

- [workflow.md](workflow.md) — the full lifecycle and the OpenSpec gate.
- [issue-tracker.md](issue-tracker.md) — reading/writing issues and the
  bidirectional linkage in detail.
- [optional-components.md](optional-components.md) — what the no-tracker path still
  guarantees.
