# issue-tracking Specification

## Purpose
TBD - created by archiving change optional-issue-tracker-binding. Update Purpose after archive.
## Requirements
### Requirement: Runtime tracker detection

Lifecycle skills SHALL detect the available issue tracker at runtime rather than
assuming one. Detection MUST probe, in order, whether the Linear MCP tools
(`mcp__linear-server__*`) are available in the current session, and whether the
`gh` CLI is installed and authenticated (`gh auth status` exits cleanly). No skill
SHALL hardcode the assumption that any particular tracker is present.

#### Scenario: Linear MCP available in session

- **WHEN** a lifecycle skill runs and the `mcp__linear-server__*` tools are present
  in the session
- **THEN** detection resolves the active mode to Linear without checking for `gh`

#### Scenario: Linear absent but gh authenticated

- **WHEN** a lifecycle skill runs, the Linear MCP tools are not present, and
  `gh auth status` succeeds
- **THEN** detection resolves the active mode to GitHub Issues

#### Scenario: Neither tracker available

- **WHEN** a lifecycle skill runs, the Linear MCP tools are not present, and
  `gh auth status` fails or `gh` is not installed
- **THEN** detection resolves the active mode to none rather than raising an error

### Requirement: Selection order and no-tracker fallback

The plugin SHALL select the active tracker by a fixed precedence: Linear MCP if
present, else GitHub Issues if `gh` is authenticated, else no tracker. When the
active mode is none, the skill SHALL proceed — the change remains tracked by its
OpenSpec change folder, its jj bookmark, and its GitHub PR — and SHALL clearly
state that no issue was recorded. Linear SHALL never be a hard requirement.

#### Scenario: Linear preferred over gh when both available

- **WHEN** both the Linear MCP tools and an authenticated `gh` are available
- **THEN** the skill operates in Linear mode and does not create a GitHub issue

#### Scenario: No-tracker mode still completes the change

- **WHEN** the active mode is none
- **THEN** the skill completes its lifecycle step without creating any issue and
  states that no issue was recorded, noting that the change is still tracked by its
  OpenSpec change folder, jj bookmark, and GitHub PR

### Requirement: Bidirectional linkage in Linear mode

In Linear mode the plugin SHALL wire PR↔issue links in both directions explicitly,
because the jj bookmark `<type>/<slug>` carries no tracker identifier and nothing
auto-links. The PR body SHALL record the issue with a `Closes <ID>` reference and
the issue URL taken from the MCP `url` field; a Linear comment SHALL be added to
the issue carrying the PR URL; and the issue status SHALL be moved to `In Review`.

#### Scenario: PR records the Linear issue

- **WHEN** the PR is opened for a change tracked by a Linear issue
- **THEN** the PR body contains `Closes <ID>` and the issue URL from the MCP `url`
  field

#### Scenario: Linear issue records the PR

- **WHEN** the PR is opened in Linear mode
- **THEN** a comment is added to the Linear issue (via `save_comment`) carrying the
  PR URL, and the issue status is set to `In Review`

### Requirement: Bidirectional linkage in GitHub mode

In GitHub Issues mode the plugin SHALL wire PR↔issue links in both directions
explicitly. The PR body SHALL record the issue with a `Closes #<n>` reference, and
the issue SHALL receive a comment or cross-reference carrying the PR.

#### Scenario: PR records the GitHub issue

- **WHEN** the PR is opened for a change tracked by a GitHub issue
- **THEN** the PR body contains `Closes #<n>` referencing that issue number

#### Scenario: GitHub issue records the PR

- **WHEN** the PR is opened in GitHub mode
- **THEN** the issue receives a comment or cross-reference linking to the PR so the
  link exists from the issue side as well as the PR side

### Requirement: Runtime config discovery and scaffolded doc

In Linear mode the plugin SHALL NOT hardcode the team, labels, or statuses; it
SHALL discover them at runtime via `list_teams`, `list_issue_labels`, and
`list_issue_statuses`. The plugin SHALL scaffold an editable
`docs/agents/issue-tracker.md` in the consuming repo that pins the chosen team and
records the conventions. When that doc is present it SHALL be treated as the source
of truth in preference to re-discovery.

#### Scenario: Team and vocabulary discovered, not hardcoded

- **WHEN** the plugin operates in Linear mode and no `docs/agents/issue-tracker.md`
  exists yet
- **THEN** the team is resolved via `list_teams` and the label/status vocabulary
  via `list_issue_labels` / `list_issue_statuses`, with no hardcoded team id, label
  names, or status names

#### Scenario: Scaffolded doc is the source of truth

- **WHEN** `docs/agents/issue-tracker.md` already exists in the consuming repo
- **THEN** the plugin reads the pinned team and conventions from that doc rather
  than re-discovering them, and treats the doc as authoritative

### Requirement: Triage-label mapping

The plugin SHALL map the five canonical triage roles (`needs-triage`,
`needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) to the active
tracker's mechanisms. In
Linear the mapping SHALL be a documented mix of statuses and labels:
`needs-triage` → status `Backlog`, `wontfix` → status `Canceled`, and
`needs-info` / `ready-for-agent` / `ready-for-human` as labels. In GitHub the five
roles SHALL map to labels. The active mapping SHALL be recorded in the scaffolded
`docs/agents/issue-tracker.md`.

#### Scenario: Canonical roles map in Linear mode

- **WHEN** a skill applies a triage role in Linear mode
- **THEN** `needs-triage` sets status `Backlog`, `wontfix` sets status `Canceled`,
  and `needs-info` / `ready-for-agent` / `ready-for-human` are applied as labels

#### Scenario: Canonical roles map in GitHub mode

- **WHEN** a skill applies a triage role in GitHub mode
- **THEN** all five canonical roles are applied as GitHub labels, with the mapping
  recorded in the scaffolded doc

### Requirement: Per-skill mode surfacing

Each lifecycle skill that touches issues SHALL announce which mode it is operating
in — Linear, GitHub, or none — so the user is never misled about where the record
lives.

#### Scenario: Skill announces its active mode

- **WHEN** a lifecycle skill performs an issue-related step
- **THEN** it states whether it is operating in Linear, GitHub, or none mode before
  or while recording (or declining to record) the issue

