# Issue-tracking binding (optional)

Issue tracking is a **pluggable binding chosen at runtime**, so the plugin works with or
without Linear. Any skill that reads or writes an issue resolves the binding first and
**states which mode it is in** so the user is never misled about where the record lives.

## Selection order (probe, don't assume)

1. **Linear MCP present** — the `mcp__linear-server__*` tools are available in the session
   → **Linear mode**.
2. **Else `gh` available** — `gh auth status` succeeds → **GitHub Issues mode**.
3. **Else neither** — **no-tracker mode**: proceed without an issue. The change is still
   tracked by its OpenSpec change folder, its jj bookmark `<type>/<slug>`, and the PR. Say
   explicitly that no issue was recorded.

## Operations by mode

| Operation | Linear mode | GitHub mode | No-tracker mode |
|-----------|-------------|-------------|-----------------|
| Find/avoid dupes | `list_issues` (team) | `gh issue list --search` | — |
| Create issue | `save_issue` (team, title, markdown body) | `gh issue create` | — (note it) |
| Read issue | `get_issue` + `list_comments` | `gh issue view --comments` | — |
| Comment | `save_comment` | `gh issue comment` | — |
| Status / label | `save_issue` (`state`, `labels` — full set, Linear replaces) | `gh issue edit --add-label` / close | — |
| Identifier | `PTS-123` (+ `url` field) | `#123` (+ URL) | the slug |

Send **real newlines** in markdown bodies, never literal `\n`.

## Bidirectional issue↔PR linkage (every mode that has an issue)

The bookmark `<type>/<slug>` carries **no** identifier, so nothing auto-links. Wire both ends:

- **PR records the issue** — PR body has a closing keyword and the issue reference.
  Linear: `Closes PTS-123` + the issue `url` returned by the MCP (never hand-build a
  `linear.app/...` URL). GitHub: `Closes #123`.
- **Issue records the PR** — Linear: `save_comment` with the PR URL + `save_issue`
  `state: "In Review"`. GitHub: `gh issue comment` with the PR URL (the closing keyword
  also cross-references it).

Verify both directions before reporting done — don't assume an integration did it.

## Runtime config discovery (Linear mode)

Team / label / status names are **not hardcoded**. Discover them with `list_teams`,
`list_issue_labels`, `list_issue_statuses`. If the consuming repo has
`docs/agents/issue-tracker.md`, it is the **source of truth** — read it first and skip
re-discovery. If it doesn't exist, offer to scaffold it from
`references/issue-tracker-template.md` so the choice is pinned for next time.

See `references/triage-labels.md` for the canonical role → mechanism mapping.
