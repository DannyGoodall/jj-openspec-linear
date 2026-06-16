# documentation

## ADDED Requirements

### Requirement: Root README

The repository SHALL contain a `README.md` at its root that covers, at minimum:
what the `change-lifecycle` plugin is; the `jj-vcs` plugin as a hard
prerequisite and the Linear MCP as an optional addon; how to install the plugin
via the `jj-openspec-linear` marketplace; a quickstart that walks the lifecycle
end to end; and a link into the `docs/` directory for deeper reference.

#### Scenario: README states purpose, prerequisite, and optional addon

- **WHEN** a new user opens the repository's `README.md`
- **THEN** it explains that the plugin packages a tracked, human-paced
  code-change lifecycle on jj workspaces with OpenSpec proposals
- **AND** it names `jj-vcs` as a required prerequisite and the Linear MCP as an
  optional addon

#### Scenario: README documents marketplace install

- **WHEN** a user wants to install the plugin
- **THEN** the `README.md` describes adding the `jj-openspec-linear` marketplace
  and installing the single `change-lifecycle` plugin from it

#### Scenario: README gives a lifecycle quickstart and links to docs

- **WHEN** a user reads the `README.md` to run their first change
- **THEN** it provides a quickstart covering the lifecycle from triage through
  teardown
- **AND** it links into the `docs/` directory for the detailed references

### Requirement: Features reference

The `docs/` directory SHALL contain a features reference that documents each
lifecycle skill — `triage-change`, `start-change`, `make-change`, `end-change`,
`teardown-change`, and `change-context` — describing for each what it does and
what it explicitly does NOT do.

#### Scenario: Features reference covers every lifecycle skill

- **WHEN** a user reads the features reference in `docs/`
- **THEN** it includes an entry for each of `triage-change`, `start-change`,
  `make-change`, `end-change`, `teardown-change`, and `change-context`

#### Scenario: Each skill entry states scope boundaries

- **WHEN** a user reads any skill entry in the features reference
- **THEN** it states what that skill does AND what it does not do (for example
  that `make-change` implements but does not open the PR, and `teardown-change`
  removes but does not merge)

### Requirement: Workflow guide

The `docs/` directory SHALL contain a workflow guide that walks the full
lifecycle path triage → start → make → end → (merge) → teardown, and that
explains the OpenSpec gate decision (when a change warrants a formal proposal)
and the slug-coordination model (one kebab-case slug naming the workspace
directory, the `<type>/<slug>` bookmark, and the OpenSpec change-id).

#### Scenario: Workflow guide walks the full lifecycle path

- **WHEN** a user reads the workflow guide
- **THEN** it describes the ordered path
  triage → start → make → end → (merge) → teardown as a single narrative

#### Scenario: Workflow guide explains the OpenSpec gate

- **WHEN** a user needs to decide whether a change requires an OpenSpec proposal
- **THEN** the workflow guide explains the OpenSpec gate decision criteria

#### Scenario: Workflow guide explains slug coordination

- **WHEN** a user reads how a change stays coordinated across artifacts
- **THEN** the workflow guide explains that one kebab-case slug names the jj
  workspace directory, the `<type>/<slug>` bookmark, and the OpenSpec change-id

### Requirement: Optional components doc

The `docs/` directory SHALL contain a doc describing how the plugin behaves WITH
versus WITHOUT the optional Linear MCP, including the `gh`-based GitHub Issues
fallback used when the Linear MCP is absent.

#### Scenario: Doc contrasts Linear-present and Linear-absent behaviour

- **WHEN** a user reads the optional components doc
- **THEN** it describes how the lifecycle behaves when the Linear MCP is
  available AND how it behaves when it is not

#### Scenario: Doc documents the GitHub Issues fallback

- **WHEN** the Linear MCP is not configured
- **THEN** the optional components doc explains that the plugin falls back to
  GitHub Issues via the `gh` CLI

### Requirement: Example prompts doc

The `docs/` directory SHALL contain an example-prompts doc giving concrete user
phrasings that trigger each lifecycle skill.

#### Scenario: Example prompts cover each skill

- **WHEN** a user reads the example-prompts doc
- **THEN** it provides at least one concrete user phrasing that triggers each of
  `triage-change`, `start-change`, `make-change`, `end-change`,
  `teardown-change`, and `change-context`

### Requirement: Issue-tracker interaction doc

The `docs/` directory SHALL contain a doc describing how the plugin reads and
writes issues in BOTH Linear and GitHub, and how it maintains the bidirectional
linkage between an issue and its pull request.

#### Scenario: Doc covers both trackers

- **WHEN** a user reads the issue-tracker interaction doc
- **THEN** it describes how the plugin reads and writes Linear issues AND how it
  reads and writes GitHub issues

#### Scenario: Doc documents bidirectional issue↔PR linkage

- **WHEN** a change is shipped as a PR
- **THEN** the issue-tracker interaction doc explains that the PR records the
  issue AND the issue records the PR

### Requirement: GitHub change-proposal doc

The `docs/` directory SHALL contain a doc describing how an OpenSpec proposal
travels into the pull request — the code change and the archived specs landing
together — and how the resulting PR records the originating issue.

#### Scenario: Doc explains proposal-to-PR flow

- **WHEN** a user reads the GitHub change-proposal doc
- **THEN** it explains how an OpenSpec proposal reaches the PR with the code and
  the archived specs together

#### Scenario: Doc explains how the PR records the issue

- **WHEN** a change ships as a PR
- **THEN** the GitHub change-proposal doc explains how the PR records its
  originating issue
