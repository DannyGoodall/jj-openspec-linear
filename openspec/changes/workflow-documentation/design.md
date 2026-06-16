# Design: workflow-documentation

## Context

The `change-lifecycle` plugin is installable and its behaviour is specified
(`change-lifecycle`, `workspace-context`, `change-triage`, `issue-tracking`),
but nothing greets a user at the front door. A person who adds the
`jj-openspec-linear` marketplace and installs the plugin lands in a repo whose
only explanatory text is inside SKILL.md descriptions and OpenSpec specs —
written for the Claude Code loader and for contributors, not for an installer
who wants to run their first tracked change.

This change specifies the user-facing documentation as a contract: a root
README for orientation and a `docs/` reference set for depth. The audience is
plugin installers and users, not maintainers of the spec. The prose itself is
authored by a later step; this change only pins down which documents must exist
and what each must cover.

## Goals / Non-Goals

Goals:
- Specify a root `README.md` that orients a new installer (what / prerequisite /
  optional addon / install / quickstart / link to docs).
- Specify a `docs/` reference set that covers features, the end-to-end workflow,
  optional components, example prompts, issue-tracker interaction, and the
  GitHub change-proposal flow.
- Make the documentation surface a deliberate contract, so coverage is verified
  against requirements rather than left to chance.

Non-Goals:
- Authoring the README or docs prose (a later step does this).
- Re-specifying skill behaviour — the docs describe the existing
  `change-lifecycle`, `workspace-context`, `change-triage`, and `issue-tracking`
  capabilities; they do not change them.
- Adding generated API docs, a docs site, or tooling — these are plain Markdown
  files.

## Decisions

### Single README + flat docs/ folder

We use one root `README.md` as the orientation surface and a single flat `docs/`
folder for the reference set, rather than nesting subfolders or a docs-site
generator. The plugin is small and the audience reads top-to-bottom; a flat set
of Markdown files is the lowest-friction structure for both authors and readers,
and keeps the documents greppable from the repo root.

### One doc per concern, named by concern

Each `docs/` file owns exactly one concern — features, workflow, optional
components, example prompts, issue-tracker interaction, GitHub change-proposals —
so a reader (and the spec) can map a requirement to a file. The tasks list pairs
one task with one file to keep that mapping explicit. Exact filenames are an
authoring detail; the spec pins the coverage, not the filename.

### README is orientation, docs/ is depth

The README must be self-sufficient for a first run (install + quickstart) and
must hand off to `docs/` for everything deeper. This split avoids a sprawling
README while ensuring the front door never dead-ends.

## Risks / Trade-offs

- **Docs drift from behaviour.** If the lifecycle skills change, the docs can go
  stale. Mitigation: the docs are specified against the same capabilities they
  describe, so the spec is the checkpoint when behaviour changes.
- **Coverage vs prose quality.** A contract pins coverage but not readability;
  thin prose can technically satisfy a scenario. Mitigation: scenarios require
  substantive coverage (per-skill entries, scope boundaries, contrasted
  with/without behaviour) rather than mere mention.
- **Filename coupling.** Pinning exact filenames in the spec would make harmless
  renames spec-breaking. Mitigation: the spec pins coverage and the `docs/`
  location; filenames live in tasks.md as the authoring plan.
