# Tasks: optional-issue-tracker-binding

## 1. Runtime detection helper

- [ ] 1.1 Specify a detection-helper contract that probes the session for the
      `mcp__linear-server__*` tools (Linear mode candidate)
- [ ] 1.2 Specify the detection-helper fallback probe: `gh` installed and
      `gh auth status` exits cleanly (GitHub mode candidate)
- [ ] 1.3 Specify the precedence resolution Linear → GitHub → none and the returned
      active-mode value the lifecycle skills consume
- [ ] 1.4 Specify the no-tracker (none) path: complete the step, state no issue was
      recorded, name the change-folder + bookmark + PR substrate

## 2. Create issue

- [ ] 2.1 Linear path: create the issue via `save_issue` on the discovered team
- [ ] 2.2 gh path: create the issue via `gh issue create`
- [ ] 2.3 none path: skip issue creation and announce that no issue was recorded

## 3. Comment on issue

- [ ] 3.1 Linear path: comment via `save_comment` with the PR URL in the body
- [ ] 3.2 gh path: comment/cross-reference the issue with the PR (e.g.
      `gh issue comment`)
- [ ] 3.3 none path: skip commenting and announce that no issue was updated

## 4. Set status / label (triage-role mapping)

- [ ] 4.1 Linear path: apply triage roles as the documented status+label mix
      (needs-triage→Backlog, wontfix→Canceled; needs-info / ready-for-agent /
      ready-for-human as labels) via `save_issue`
- [ ] 4.2 Linear path: move status to `In Review` when the PR opens
- [ ] 4.3 gh path: apply all five triage roles as GitHub labels
      (e.g. `gh issue edit --add-label`)
- [ ] 4.4 none path: skip status/label application and announce no tracker state

## 5. Link PR ↔ issue (bidirectional)

- [ ] 5.1 Linear path, PR side: write `Closes <ID>` + the issue `url` into the PR
      body
- [ ] 5.2 Linear path, issue side: ensure the `save_comment` PR-URL comment exists
      so the link is wired from the issue side too
- [ ] 5.3 gh path, PR side: write `Closes #<n>` into the PR body
- [ ] 5.4 gh path, issue side: ensure the issue comment/cross-reference to the PR
      exists so the link is wired from the issue side too
- [ ] 5.5 none path: note that the PR is the sole record and no issue link exists

## 6. Runtime config discovery + scaffolded doc

- [ ] 6.1 Linear path: discover the team via `list_teams`, labels via
      `list_issue_labels`, statuses via `list_issue_statuses` — no hardcoded values
- [ ] 6.2 Doc scaffolder: write an editable `docs/agents/issue-tracker.md` pinning
      the chosen team and recording the conventions when absent
- [ ] 6.3 Doc scaffolder: when `docs/agents/issue-tracker.md` exists, read it as the
      source of truth instead of re-discovering
- [ ] 6.4 Doc scaffolder: record the active triage-role → tracker-mechanism mapping
      in the scaffolded doc

## 7. Mode surfacing

- [ ] 7.1 Specify that each issue-touching lifecycle skill announces its active mode
      (Linear / GitHub / none) at the issue step

## 8. Validation

- [ ] 8.1 Run `openspec validate optional-issue-tracker-binding --strict` until it
      passes
