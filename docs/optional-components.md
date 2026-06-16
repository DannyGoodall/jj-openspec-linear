# Optional components — Linear, GitHub Issues, or no tracker

The hard prerequisite for `change-lifecycle` is the **`jj-vcs`** plugin (all jj
mechanics are delegated to it). Everything else about the issue tracker is
optional. Issue tracking is a **pluggable binding discovered at runtime** — the
plugin adapts to whatever the session offers, with no configuration step and no
install-time dependency on Linear.

This doc covers what changes WITH versus WITHOUT the Linear MCP. For the
mechanics of reading/writing issues and the field-level mapping, see
[issue-tracker.md](issue-tracker.md).

## Selection order

Each issue-touching skill detects the active tracker at runtime, in fixed
precedence, and the first hit wins:

```text
1. Linear MCP present?   (mcp__linear-server__* tools available in the session)   → Linear mode
2. else gh authenticated? (gh installed and `gh auth status` exits cleanly)        → GitHub mode
3. else                                                                            → no-tracker mode
```

Linear is **preferred** when available but **never required**. If both Linear and
an authenticated `gh` are present, the skill operates in Linear mode and does not
create a GitHub issue.

Every skill that touches issues **announces its active mode** (Linear / GitHub /
none) so you are never misled about where the record lives.

## With the Linear MCP (Linear mode)

- Issues are created, read, labelled, commented on, and status-changed via the
  `mcp__linear-server__*` tools.
- Team, labels, and statuses are **discovered at runtime** (`list_teams`,
  `list_issue_labels`, `list_issue_statuses`) — nothing is hardcoded — and pinned
  into an editable `docs/agents/issue-tracker.md` that then becomes the source of
  truth.
- Triage roles map to a documented mix of statuses and labels: `needs-triage` →
  status `Backlog`, `wontfix` → status `Canceled`, and `needs-info` /
  `ready-for-agent` / `ready-for-human` as labels.
- When `end-change` opens the PR, the PR body records `Closes <ID>` + the issue
  URL, a Linear comment carrying the PR URL is added to the issue, and the issue
  moves to **In Review**.

## Without the Linear MCP, with `gh` (GitHub mode)

- The plugin falls back to **GitHub Issues via the `gh` CLI**.
- Issues are created, read, labelled, and commented on with `gh`.
- All five triage roles (`needs-triage`, `needs-info`, `ready-for-agent`,
  `ready-for-human`, `wontfix`) map to **GitHub labels** (GitHub has no separate
  workflow-status mechanism), with the mapping recorded in the scaffolded doc.
- When `end-change` opens the PR, the PR body records `Closes #<n>` and the issue
  receives a comment/cross-reference carrying the PR.

## Without either (no-tracker mode)

Absence of a tracker is a **first-class, supported path**, not an error. The skill
completes its lifecycle step, creates no issue, and **states plainly that no issue
was recorded**.

What no-tracker mode still guarantees — the change is fully tracked by the
substrate that is always present:

- the **OpenSpec change folder** (proposal, tasks, specs);
- the **jj bookmark** `<type>/<slug>`; and
- the **GitHub pull request**.

So a change is never "lost" for lack of a tracker — it just has no issue record,
and the skill says so.

## Summary

| | Linear mode | GitHub mode | No-tracker mode |
|---|---|---|---|
| Detection | `mcp__linear-server__*` present | `gh auth status` succeeds | neither |
| Issue store | Linear MCP | GitHub Issues via `gh` | none |
| Triage roles | statuses + labels | labels | n/a |
| PR → issue link | `Closes <ID>` + URL | `Closes #<n>` | n/a |
| Issue → PR link | Linear comment + In Review | issue comment / cross-ref | n/a |
| Change still tracked by | OpenSpec folder + bookmark + PR | OpenSpec folder + bookmark + PR | OpenSpec folder + bookmark + PR |

See also [issue-tracker.md](issue-tracker.md) and
[github-proposals.md](github-proposals.md).
