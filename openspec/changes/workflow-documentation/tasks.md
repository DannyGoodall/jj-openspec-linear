# Tasks: workflow-documentation

## 1. Root README

- [x] 1.1 Produce `README.md` at the repo root covering: what the plugin is; the
  `jj-vcs` prerequisite and Linear-optional addon; marketplace install of the
  single `change-lifecycle` plugin; a lifecycle quickstart; and a link into
  `docs/`.

## 2. docs/ reference set

- [x] 2.1 Produce `docs/features.md` documenting each lifecycle skill
  (`triage-change`, `start-change`, `make-change`, `end-change`,
  `teardown-change`, `change-context`) with what it does and does not do.
- [x] 2.2 Produce `docs/workflow.md` walking
  triage → start → make → end → (merge) → teardown, including the OpenSpec gate
  decision and the slug-coordination model.
- [x] 2.3 Produce `docs/optional-components.md` describing behaviour WITH vs
  WITHOUT the Linear MCP and the `gh` GitHub-Issues fallback.
- [x] 2.4 Produce `docs/example-prompts.md` with concrete user phrasings that
  trigger each lifecycle skill.
- [x] 2.5 Produce `docs/issue-tracker.md` covering how the plugin reads/writes
  Linear issues AND GitHub issues, and the bidirectional issue↔PR linkage.
- [x] 2.6 Produce `docs/github-proposals.md` describing how an OpenSpec proposal
  travels into the PR (code + archived specs together) and how the PR records
  the issue.
