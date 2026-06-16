# documentation

## MODIFIED Requirements

### Requirement: Issue-tracker interaction doc

The `docs/` directory SHALL contain a doc describing how the plugin reads and
writes issues in BOTH Linear and GitHub, how it maintains the bidirectional
linkage between an issue and its pull request, AND a gallery of complete worked
`docs/agents/issue-tracker.md` example configurations covering the supported
binding permutations.

#### Scenario: Doc covers both trackers

- **WHEN** a user reads the issue-tracker interaction doc
- **THEN** it describes how the plugin reads and writes Linear issues AND how it
  reads and writes GitHub issues

#### Scenario: Doc documents bidirectional issue↔PR linkage

- **WHEN** a change is shipped as a PR
- **THEN** the issue-tracker interaction doc explains that the PR records the
  issue AND the issue records the PR

#### Scenario: Doc provides worked example configurations

- **WHEN** a user reads the issue-tracker interaction doc to author their repo's
  `docs/agents/issue-tracker.md`
- **THEN** it presents complete, captioned example configurations covering at
  least Linear-pinned, GitHub-pinned, no-tracker, and the case where the Linear
  MCP is present in the session but the repo is pinned to GitHub
- **AND** each example is marked as commentary so it is not mistaken for the
  consuming repo's single live config
