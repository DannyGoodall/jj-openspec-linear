# Triage labels (canonical roles → tracker mechanisms)

The skills speak in five canonical triage **roles**. Each tracker represents them
differently. Apply the mechanism for the active issue-tracking mode (see
`references/issue-tracking.md`).

| Canonical role    | Linear mechanism            | GitHub mechanism                  | Meaning                                  |
|-------------------|-----------------------------|-----------------------------------|------------------------------------------|
| `needs-triage`    | status `Backlog`            | open, label `needs-triage`        | Maintainer needs to evaluate this        |
| `needs-info`      | label `needs-info`          | label `needs-info`                | Waiting on the reporter                  |
| `ready-for-agent` | label `ready-for-agent` (+ status `Todo`) | label `ready-for-agent` | Fully specified, ready for an AFK agent  |
| `ready-for-human` | label `ready-for-human` (+ status `Todo`) | label `ready-for-human` | Requires human implementation            |
| `wontfix`         | status `Canceled`           | close as not planned, label `wontfix` | Will not be actioned                 |

## Notes

- **Linear statuses are mutually exclusive; labels stack.** Moving an issue to
  `ready-for-agent`/`ready-for-human` typically also sets status `Todo`.
- `save_issue`'s `labels` array **replaces** the whole set — include the categorical
  label (`Bug`/`Feature`/`Improvement`) you want to keep alongside the triage label.
- Discover the exact team/label/status names at runtime (`list_issue_labels`,
  `list_issue_statuses`); if a triage label is missing, create it
  (`create_issue_label`). In GitHub mode, `gh label create` as needed.
- The chosen names are pinned in the consuming repo's `docs/agents/issue-tracker.md`
  when scaffolded.
