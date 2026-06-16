# workflow-documentation

## Why

The `change-lifecycle` plugin packages a real, opinionated workflow — a tracked,
human-paced code-change lifecycle on jj workspaces, OpenSpec proposals, and an
optional issue tracker — but a freshly-installed user has no entry point that
explains what they just installed or how to drive it. Today the only narrative
lives inside individual SKILL.md descriptions and OpenSpec specs, which are
written for the loader and for contributors, not for an installer trying to run
their first change. Without a root README and a `docs/` set, the plugin's
behaviour (the jj-vcs prerequisite, the Linear-optional addon and its
GitHub-Issues fallback, the slug-coordination triple, the OpenSpec gate, the
ship-as-PR rule) is discoverable only by reading source. This change specifies
those user-facing documents as a contract so the docs cover the required
surface deliberately rather than ad-hoc.

## What Changes

- Add a `documentation` capability that specifies the **root README** and the
  **`docs/` reference set** as required deliverables, pinning the coverage each
  must provide.
- Require the **README** to state what the plugin is, declare the `jj-vcs`
  prerequisite and the Linear-optional addon, document marketplace install, give
  a lifecycle quickstart, and link into `docs/`.
- Require a **features reference** that covers every lifecycle skill
  (`triage-change`, `start-change`, `make-change`, `end-change`,
  `teardown-change`, `change-context`) with what each does and does not do.
- Require a **workflow guide** that walks the full path
  triage → start → make → end → (merge) → teardown, including the OpenSpec gate
  decision and the slug-coordination model.
- Require an **optional-components doc** describing behaviour WITH vs WITHOUT the
  Linear MCP, and the `gh` GitHub-Issues fallback.
- Require an **example-prompts doc** with concrete user phrasings that trigger
  each skill.
- Require an **issue-tracker interaction doc** covering how the plugin
  reads/writes Linear issues AND GitHub issues, plus the bidirectional
  issue↔PR linkage.
- Require a **GitHub change-proposal doc** describing how an OpenSpec proposal
  travels into the PR (code + archived specs together) and how the PR records
  the issue.

This change specifies the documents only; the prose itself is produced by a
separate step.

## Capabilities

### New Capabilities

- `documentation`: the required user-facing documentation surface — a root
  README plus a `docs/` reference set (features, workflow, optional components,
  example prompts, issue-tracker interaction, GitHub change-proposal) — with the
  coverage each document must provide.

### Modified Capabilities

_None._

## Impact

- Adds one OpenSpec capability spec, `documentation`, under `openspec/specs/`
  once archived.
- Establishes the contract for the repo's `README.md` and `docs/` folder; the
  files are authored by a later step, not by this change.
- References the `change-lifecycle`, `workspace-context`, `change-triage`, and
  `issue-tracking` capabilities for the behaviour the docs describe, but adds no
  runtime code — artifacts only.
