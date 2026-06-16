# Issue tracker (pin this repo's conventions)

> Scaffold target: write this to `docs/agents/issue-tracker.md` in the consuming repo,
> fill the placeholders once, and it becomes the source of truth — skills read it instead
> of re-discovering the tracker each session. Delete the modes you don't use.

## Mode

This repo uses: **`<linear | github | none>`** for issue tracking.

## Linear coordinates (Linear mode)

- **Team**: `<TEAM NAME>` (`<team-id>`) — discover with `list_teams`.
- **Projects**: `<none | names>`.
- **Identifier prefix**: `<e.g. PTS>`.
- Create: `save_issue` (`team`, `title`, markdown `description`, real newlines).
- Read: `get_issue` (+ `list_comments`). List: `list_issues` filtered by team.
- Comment: `save_comment`. Status/labels: `save_issue` (`labels` replaces the full set).

## GitHub coordinates (GitHub mode)

- **Repo**: `<owner/repo>` (or `gh repo set-default`).
- Create: `gh issue create`. Read: `gh issue view --comments`. Comment: `gh issue comment`.
- Labels: `gh issue edit --add-label` / `gh label create`.

## Triage labels

See the plugin's `references/triage-labels.md` for the canonical role → mechanism map.
The three triage labels (`needs-info`, `ready-for-agent`, `ready-for-human`) must exist
on this tracker; create them if missing.
