# Issue tracker (this repo's pinned conventions)

> Source of truth for the change-lifecycle plugin's issue-tracking binding. Because this
> file exists, skills read it instead of re-probing — and its **Mode** below is
> authoritative even when the Linear MCP happens to be present in the session.

## Mode

This repo uses: **`github`** for issue tracking.

## GitHub coordinates (GitHub mode)

- **Repo**: `DannyGoodall/jj-openspec-linear`.
- Create: `gh issue create`. Read: `gh issue view --comments`. Comment: `gh issue comment`.
- Labels: `gh issue edit --add-label` / `gh label create`.

## Triage labels

Canonical role → mechanism map lives in the plugin's `references/triage-labels.md`.
In this repo all five roles are GitHub **labels** (`needs-triage`, `needs-info`,
`ready-for-agent`, `ready-for-human`, `wontfix`); create any that are missing with
`gh label create`.
