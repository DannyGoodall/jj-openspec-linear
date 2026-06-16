# Issue-tracker interaction

Issue tracking is a **pluggable binding discovered at runtime** — Linear via its
MCP server when present, GitHub Issues via the `gh` CLI as a fallback, or no
tracker at all. This doc covers how the plugin reads and writes issues in **both**
modes, how it discovers its runtime configuration, the triage-label mapping, and
the **bidirectional issue↔PR linkage** that holds in both modes.

For the selection order and the no-tracker guarantees, see
[optional-components.md](optional-components.md). For how the OpenSpec proposal and
the issue both reach the PR, see [github-proposals.md](github-proposals.md). For
complete, copy-ready config files, see **[Worked examples](#worked-examples)** at
the end of this doc.

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

## Worked examples

> [!IMPORTANT]
> **These blocks are illustrative commentary, not live configuration.** A
> consuming repo has exactly **one** `docs/agents/issue-tracker.md`, scaffolded
> from [`references/issue-tracker-template.md`](../plugins/change-lifecycle/references/issue-tracker-template.md)
> and pinned to a single mode. The five examples below show different *repos'*
> files side by side so you can see each permutation — **do not concatenate them
> into one file.** Skills only ever read the consuming repo's own
> `docs/agents/issue-tracker.md`; they never read this doc as config.

Each example is a complete file. Pick the one matching how your repo tracks
issues, drop it at `docs/agents/issue-tracker.md`, and edit the coordinates.

### Example 1 — Linear, pinned

A repo whose issues live in Linear, with the team and identifier prefix pinned so
discovery never has to guess.

```markdown
# Issue tracker (this repo's pinned conventions)

> Source of truth for the change-lifecycle plugin's issue-tracking binding.
> Because this file exists, skills read it instead of re-probing.

## Mode

This repo uses: **`linear`** for issue tracking.

## Linear coordinates (Linear mode)

- **Team**: `Points2026` (`8c795f6f-755c-4b9d-b720-e69bd60171e6`).
- **Projects**: none.
- **Identifier prefix**: `PTS`.
- Create: `save_issue` (`team`, `title`, markdown `description`, real newlines).
- Read: `get_issue` (+ `list_comments`). List: `list_issues` filtered by team.
- Comment: `save_comment`. Status/labels: `save_issue` (`labels` replaces the full set).

## Triage labels

`needs-triage` → status `Backlog`, `wontfix` → status `Canceled`; `needs-info` /
`ready-for-agent` / `ready-for-human` are labels.
```

### Example 2 — GitHub, pinned

A repo with no Linear MCP that uses GitHub Issues via the `gh` CLI. All five
triage roles are GitHub labels.

```markdown
# Issue tracker (this repo's pinned conventions)

## Mode

This repo uses: **`github`** for issue tracking.

## GitHub coordinates (GitHub mode)

- **Repo**: `DannyGoodall/jj-openspec-linear`.
- Create: `gh issue create`. Read: `gh issue view --comments`. Comment: `gh issue comment`.
- Labels: `gh issue edit --add-label` / `gh label create`.

## Triage labels

All five roles are GitHub labels (`needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`); create any that are missing.
```

### Example 3 — No tracker (`Mode: none`)

A repo that deliberately tracks changes without an issue store. This is a
first-class, supported choice — not an empty or missing file.

```markdown
# Issue tracker (this repo's pinned conventions)

## Mode

This repo uses: **`none`** for issue tracking.

> No issue store. Each change is tracked by its OpenSpec change folder, its jj
> bookmark `<type>/<slug>`, and its PR. Skills will say plainly that no issue was
> recorded.
```

### Example 4 — Linear MCP present, but pinned to `github` (anti-hijack)

The counterintuitive one. The Linear MCP is connected in the session (so the
runtime probe would pick Linear first), but **this** repo's issues live on
GitHub. Pinning `github` makes the GitHub binding authoritative — the pinned
`Mode` wins over the probe, so the session's Linear MCP does not hijack it.

```markdown
# Issue tracker (this repo's pinned conventions)

> The Linear MCP is connected in our sessions, but THIS repo's issues live on
> GitHub. The pinned Mode below is authoritative and overrides runtime detection,
> so the session's Linear MCP does not hijack this repo's binding.

## Mode

This repo uses: **`github`** for issue tracking.

## GitHub coordinates (GitHub mode)

- **Repo**: `acme/widgets`.
- Create: `gh issue create`. Read: `gh issue view --comments`. Comment: `gh issue comment`.
- Labels: `gh issue edit --add-label` / `gh label create`.
```

### Example 5 — Minimal one-line Linear

The file can be almost nothing. With `Mode: linear` and no coordinates, the
plugin discovers the team, labels, and statuses at runtime. Pin coordinates later
only if discovery is ambiguous (e.g. `list_teams` returns more than one team).

```markdown
# Issue tracker (this repo's pinned conventions)

## Mode

This repo uses: **`linear`** for issue tracking.

<!-- No coordinates pinned: the plugin discovers team / labels / statuses at
     runtime via list_teams / list_issue_labels / list_issue_statuses. Add a
     "Linear coordinates" section here once discovery is ambiguous. -->
```
