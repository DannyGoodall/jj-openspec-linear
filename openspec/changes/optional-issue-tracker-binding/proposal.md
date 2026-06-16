# Change: optional-issue-tracker-binding

## Why

The lifecycle skills (triage-change → start-change → make-change → end-change →
teardown-change) all assume an issue tracker exists, and today that assumption is
baked in: the conventions are written against Linear, with a hardcoded team id,
hardcoded label names, and hardcoded workflow statuses (see the consuming repo's
`docs/agents/issue-tracker.md` and `docs/agents/triage-labels.md`). That makes the
plugin unusable for anyone who does not run the Linear MCP server, and brittle even
for those who do but use a differently-named team, labels, or statuses.

The CORE differentiator of this plugin is that issue tracking is a **pluggable
binding discovered at runtime**, not a hard dependency. The plugin must work three
ways without reconfiguration:

- with the Linear MCP server present (use Linear),
- without Linear but with the `gh` CLI authenticated (use GitHub Issues), and
- with neither (proceed with NO tracker — the change is still fully tracked by its
  OpenSpec change folder + jj bookmark + GitHub PR — and clearly say so).

The jj bookmark `<type>/<slug>` carries no tracker identifier, so nothing
auto-links between an issue and its PR. Both directions therefore have to be wired
explicitly, in whichever mode is active. And because every mode records the change
in a different place (or nowhere), each lifecycle skill must announce which mode it
is operating in so the user is never misled about where the record lives.

The Linear-optional contract is explicit: **no skill, manifest, or workflow step
SHALL require Linear to be present.** Linear is the preferred binding when
available; its absence is a supported, first-class path, never an error.

## What Changes

- Add a runtime issue-tracker **detection helper** contract: skills detect whether
  the Linear MCP (`mcp__linear-server__*`) tools are available in the session, then
  whether `gh` is installed and authenticated (`gh auth status`), and select a mode
  accordingly — Linear, else GitHub, else none.
- Specify **bidirectional PR↔issue linkage** for both Linear and GitHub modes,
  since the bookmark links nothing on its own.
- Specify **runtime config discovery** in Linear mode (team via `list_teams`,
  labels via `list_issue_labels`, statuses via `list_issue_statuses` — nothing
  hardcoded) and a **scaffolded, editable doc** (`docs/agents/issue-tracker.md`) in
  the consuming repo that pins the chosen team and records conventions; when the
  doc is present it is the source of truth.
- Specify the **triage-label mapping**: the five canonical roles (needs-triage,
  needs-info, ready-for-agent, ready-for-human, wontfix) map to the active
  tracker's mechanisms — in Linear a documented mix of statuses + labels, in GitHub
  as labels — and the mapping is recorded in the scaffolded doc.
- Specify **mode surfacing**: each lifecycle skill that touches issues announces
  whether it is operating in Linear / GitHub / none mode.
- This change generalises the consuming repo's hardcoded-Linear conventions into a
  runtime binding; it does not change the jj or PR mechanics, which remain owned by
  the lifecycle skills and the `jj-vcs` prerequisite.

## Capabilities

### New Capabilities

- `issue-tracking`: issue tracking as a pluggable binding discovered at runtime —
  Linear MCP when present, else GitHub Issues via `gh`, else none — with explicit
  bidirectional PR↔issue linkage, runtime config discovery into a scaffolded
  editable doc, a tracker-agnostic triage-label mapping, and per-skill mode
  surfacing so the plugin works WITH or WITHOUT Linear.

### Modified Capabilities

_None._

## Impact

- New spec capability: `issue-tracking`.
- New behaviour for every lifecycle skill that records, comments on, labels, or
  links an issue: it must first run detection and announce its mode.
- New scaffolded artifact in the consuming repo: an editable
  `docs/agents/issue-tracker.md` pinning the discovered team and conventions.
- No change to jj mechanics (still delegated to `jj-vcs`) or to the OpenSpec
  change folder / bookmark / PR mechanism, which remain the always-present
  tracking substrate even when no issue tracker is bound.
