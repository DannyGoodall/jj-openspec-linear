# issue-tracker-examples

## Why

The issue-tracking binding is configured per consuming repo by a single
`docs/agents/issue-tracker.md` file, but the docs only describe that file in
prose. `docs/optional-components.md` narrates the Linear / GitHub / none
selection order and `docs/issue-tracker.md` documents the field-level mapping,
yet neither shows a *complete* `docs/agents/issue-tracker.md`. An adopter has to
assemble one from the template plus scattered prose, and the most error-prone
case — the Linear MCP being present in the session while the repo is
deliberately pinned to GitHub (the "anti-hijack" override) — is described but
never shown as a working file.

A worked example gallery removes that gap. The examples belong in the plugin's
documentation file `docs/issue-tracker.md`, **not** in any consuming repo's
`docs/agents/issue-tracker.md` (the single live config the agent reads): the two
share a basename, but only the latter is read as configuration, so a gallery of
five competing configs must live in the human-facing doc and be marked
unmistakably as commentary.

## What Changes

- Amend the `documentation` capability's **Issue-tracker interaction doc**
  requirement so it also mandates a gallery of complete, worked
  `docs/agents/issue-tracker.md` example configurations covering the supported
  binding permutations, each marked as commentary rather than live config.
- Author the gallery in `docs/issue-tracker.md`: (1) Linear pinned, (2) GitHub
  pinned, (3) `Mode: none`, (4) Linear MCP present but pinned `github`
  (anti-hijack), (5) minimal one-line Linear relying on runtime discovery.
- Link to the gallery from `docs/optional-components.md`.
- Bump the plugin version `0.1.2` → `0.1.3` to mark the documentation update.

This change adds no runtime behaviour — it extends a documentation contract and
the prose that satisfies it.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `documentation`: the **Issue-tracker interaction doc** requirement gains a
  worked-example-gallery obligation covering the binding permutations.

## Impact

- Modifies the `documentation` capability spec under `openspec/specs/` once
  archived (one requirement gains a scenario).
- Updates `docs/issue-tracker.md` and `docs/optional-components.md`.
- Bumps `plugins/change-lifecycle/.claude-plugin/plugin.json` to `0.1.3`.
- No skill logic, no runtime code — documentation only.
