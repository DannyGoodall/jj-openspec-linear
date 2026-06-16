# Design: optional-issue-tracker-binding

## Context

The lifecycle skills were written against a single, hardcoded tracker: Linear via
its MCP server, with a fixed team id, fixed label names, and fixed workflow
statuses (captured in the consuming repo's `docs/agents/issue-tracker.md` and
`docs/agents/triage-labels.md`). That coupling has two costs. First, anyone without
the Linear MCP server cannot use the plugin at all. Second, even Linear users with a
differently-named team or label/status vocabulary hit wrong-name failures.

The plugin already declares Linear as an OPTIONAL addon at the packaging level
(`plugin-scaffold-and-distribution`), and `jj-vcs` as the only HARD prerequisite.
This change makes that optionality real in behaviour: a runtime binding selected by
capability detection, with a no-tracker path that still tracks the change through
the substrate that is always present — the OpenSpec change folder, the jj bookmark
`<type>/<slug>`, and the GitHub PR.

A key structural fact drives the linkage design: the jj bookmark carries no tracker
identifier. Nothing about `<type>/<slug>` tells Linear or GitHub which issue a PR
belongs to, so no automatic cross-link ever happens. Every link must be wired
explicitly, on both sides, in whichever mode is active.

## Goals / Non-Goals

Goals:

- Detect the tracker at runtime and select Linear → GitHub → none by fixed
  precedence.
- Make the no-tracker path first-class: complete the change, say no issue was
  recorded.
- Wire PR↔issue links explicitly in both directions for both Linear and GitHub.
- Discover Linear team/labels/statuses at runtime; scaffold an editable doc that
  becomes the source of truth.
- Map the five canonical triage roles onto whichever tracker is active.
- Make every issue-touching skill announce its mode.

Non-Goals:

- Changing jj mechanics (owned by `jj-vcs`) or the PR-open mechanics.
- Supporting trackers beyond Linear and GitHub Issues.
- Migrating existing issues between trackers.
- Re-specifying packaging-level optionality (done by
  `plugin-scaffold-and-distribution`).

## Decisions

**Runtime capability detection over configuration.** Skills probe the live session:
are the `mcp__linear-server__*` tools present? If not, does `gh auth status`
succeed? The first hit wins; if neither, the mode is none. This mirrors the
existing `jj-vcs:jj` capability-probe pattern and keeps the plugin install-free of
tracker config — it adapts to whatever the session offers.

**Graceful degradation rather than failure.** Absence of a tracker is a supported
path, not an error. In none mode the skill completes its step and states plainly
that no issue was recorded, pointing at the change folder + bookmark + PR as the
tracking substrate. This is what makes Linear genuinely optional.

**Pluggable binding over hardcoding.** A binding selected at runtime lets one
plugin serve Linear users, GitHub users, and tracker-less users without forks or
config flags. Hardcoding Linear (the prior state) excludes two of those three
audiences and is brittle to vocabulary drift even for the first.

**Explicit bidirectional linkage.** Because the bookmark links nothing, each mode
writes both directions. Linear: PR body gets `Closes <ID>` + the issue `url`; a
`save_comment` puts the PR URL on the issue; status → `In Review`. GitHub: PR body
gets `Closes #<n>`; the issue gets a comment/cross-ref with the PR. Writing both
sides means the link survives regardless of which artifact a reader starts from.

**Scaffold a doc rather than require config.** Instead of demanding a config file
before first use, the plugin discovers the Linear team/vocabulary at runtime and
writes an editable `docs/agents/issue-tracker.md` pinning the chosen team and
conventions. First run works with zero setup; the doc then becomes the source of
truth so subsequent runs are stable and a maintainer can hand-edit conventions. A
required config file would reintroduce the setup burden this change removes.

**Triage roles map per tracker, recorded in the doc.** The five canonical roles are
the skills' vocabulary; each tracker realises them differently. Linear uses a
status+label mix (needs-triage→Backlog, wontfix→Canceled, the three ready/info as
labels); GitHub uses labels for all five. The active mapping lives in the scaffolded
doc so it is inspectable and editable.

## Risks / Trade-offs

**gh and Linear vocabularies differ.** Linear distinguishes mutually-exclusive
workflow statuses from stacking labels; GitHub has only labels. A role that maps to
a status in Linear (needs-triage→Backlog, wontfix→Canceled) maps to a label in
GitHub, so the two trackers express the same canonical role through different
mechanisms. *Mitigation:* the canonical five roles are the stable interface;
per-tracker realisation is an implementation detail recorded in the scaffolded doc,
and `Closes`-style linkage uses each tracker's native syntax (`Closes <ID>` vs
`Closes #<n>`). Skills speak roles, not raw status/label names.

**Mode misattribution.** A user could assume an issue exists when the session ran in
none mode, or expect Linear when gh was actually selected. *Mitigation:* per-skill
mode surfacing makes the active mode explicit at every issue-touching step.

**Linear discovery returning an unexpected team.** `list_teams` may return multiple
teams or a differently-named one. *Mitigation:* the scaffolded doc pins the chosen
team once discovered and is thereafter authoritative, so discovery ambiguity is
resolved once and persisted rather than re-litigated each run.
