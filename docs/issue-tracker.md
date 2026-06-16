# Issue-tracker interaction

Issue tracking is a **pluggable binding discovered at runtime** — Linear via its
MCP server when present, GitHub Issues via the `gh` CLI as a fallback, or no
tracker at all. This doc covers how the plugin reads and writes issues in **both**
modes, how it discovers its runtime configuration, the triage-label mapping, and
the **bidirectional issue↔PR linkage** that holds in both modes.

For the selection order and the no-tracker guarantees, see
[optional-components.md](optional-components.md). For how the OpenSpec proposal and
the issue both reach the PR, see [github-proposals.md](github-proposals.md).

## Detection and mode

Before any issue operation, a skill detects the active tracker by fixed
precedence — **Linear → GitHub → none** — and announces which mode it is operating
in. (Full rules in [optional-components.md](optional-components.md).)

## Linear mode (the Linear MCP server)

All reads and writes go through the `mcp__linear-server__*` tools:

- **Create / read** issues for a change.
- **Label** an issue with the triage role.
- **Comment** on an issue (e.g. recording the PR URL via `save_comment`).
- **Status** changes (e.g. moving an issue to `In Review` when the PR opens).

### Runtime config discovery

In Linear mode the plugin does **not** hardcode the team, labels, or statuses. It
discovers them at runtime:

| What | Discovered via |
|------|----------------|
| Team | `list_teams` |
| Labels | `list_issue_labels` |
| Statuses | `list_issue_statuses` |

It then scaffolds an editable **`docs/agents/issue-tracker.md`** in the consuming
repo that pins the chosen team and records the conventions. Once that doc exists it
is treated as the **source of truth** in preference to re-discovery — so discovery
ambiguity (e.g. `list_teams` returning several teams) is resolved once and
persisted, not re-litigated every run. A maintainer can hand-edit the doc to fix
conventions.

## GitHub mode (the `gh` CLI)

When the Linear MCP is absent but `gh` is authenticated, the same operations run
against **GitHub Issues** via `gh`:

- **Create / read** issues.
- **Label** an issue with the triage role.
- **Comment** / cross-reference an issue (e.g. linking the PR).

GitHub has no separate workflow-status mechanism, so role realisation differs (see
below).

## Triage-label mapping

The skills speak the **five canonical roles**; each tracker realises them through
its own mechanism. The active mapping is recorded in the scaffolded
`docs/agents/issue-tracker.md`.

| Canonical role | Linear | GitHub |
|----------------|--------|--------|
| `needs-triage` | status `Backlog` | label |
| `wontfix` | status `Canceled` | label |
| `needs-info` | label | label |
| `ready-for-agent` | label | label |
| `ready-for-human` | label | label |

In Linear the mapping is a documented mix of statuses and labels; in GitHub all
five roles are labels. `triage-change` applies exactly one of `needs-info` /
`ready-for-agent` / `ready-for-human` as the final step of its determination.

## Bidirectional issue↔PR linkage

The jj bookmark `<type>/<slug>` carries **no tracker identifier**, so nothing
auto-links an issue to its PR. Every link is therefore wired **explicitly, on both
sides**, in whichever mode is active. `end-change` does this when it opens the PR.

### Linear mode

- **PR records the issue** — the PR body contains `Closes <ID>` and the issue URL
  taken from the MCP `url` field.
- **Issue records the PR** — a comment is added to the issue (via `save_comment`)
  carrying the PR URL, and the issue status is moved to `In Review`.

### GitHub mode

- **PR records the issue** — the PR body contains `Closes #<n>` referencing the
  issue number.
- **Issue records the PR** — the issue receives a comment / cross-reference linking
  to the PR, so the link exists from the issue side as well as the PR side.

Writing both directions means the link survives regardless of which artifact a
reader starts from. In no-tracker mode there is no issue to link; the change is
tracked by its OpenSpec folder, bookmark, and PR — see
[optional-components.md](optional-components.md).
