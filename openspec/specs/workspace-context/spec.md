# workspace-context Specification

## Purpose
TBD - created by archiving change tracked-change-lifecycle. Update Purpose after archive.
## Requirements
### Requirement: Resolve the workspace from an issue or a slug

`change-context` SHALL accept either an issue reference or a change slug and resolve it to the change's jj workspace directory at `../<slug>`. Given an issue, it MUST derive the slug via the issue-tracking binding (the slug recorded when the change was set up); given a slug, it MUST use it directly. It only SETS context — it does not implement, push, or open a PR.

#### Scenario: Resolve from an issue argument

- **WHEN** `change-context` is invoked with an issue reference whose change was set up with slug `lane-stacking`
- **THEN** it reads the issue via the issue-tracking binding, derives the slug `lane-stacking`, and targets the workspace at `../lane-stacking`

#### Scenario: Resolve from a slug argument

- **WHEN** `change-context` is invoked with the slug `lane-stacking`
- **THEN** it targets the workspace at `../lane-stacking` directly without consulting the issue tracker

### Requirement: Verify the workspace before adopting it

`change-context` SHALL verify the resolved workspace before adopting it as context: the jj workspace root MUST end in `<slug>` and `openspec list` (run with the workspace as cwd) MUST show the change. If verification fails, it MUST stop and report rather than proceed against an unverified or base checkout.

#### Scenario: Verification succeeds

- **WHEN** the resolved `../<slug>` workspace root ends in `<slug>` and `openspec list` shows the change
- **THEN** `change-context` adopts the workspace and proceeds to load its context

#### Scenario: Verification failure stops adoption

- **WHEN** the resolved workspace root does not end in `<slug>`, or `openspec list` does not show the change
- **THEN** `change-context` stops and reports the verification failure without adopting the workspace or stating a working contract

### Requirement: Load the change context

After verification, `change-context` SHALL load the change's context: for an OpenSpec change it MUST load the proposal, tasks, and (when present) design; for a code-only change it MUST load the issue body. This loaded context is what subsequent work in the session operates against.

#### Scenario: Load an OpenSpec change's artifacts

- **WHEN** `change-context` has verified an OpenSpec change's workspace
- **THEN** it loads the proposal, `tasks.md`, and any `design.md` from the workspace as the working context

#### Scenario: Load a code-only change's issue

- **WHEN** `change-context` has verified a code-only change's workspace (no OpenSpec proposal)
- **THEN** it loads the issue body as the working context

### Requirement: State and hold the working contract

`change-context` SHALL state and hold a working contract for the rest of the session: the workspace (`../<slug>`) is the cwd for all `openspec`, test, and dev commands; all workspace file operations use the native Read/Edit/Write/Grep/Glob tools on absolute `../<slug>/` paths; Serena is reserved for base-checkout work because its edit tools would silently corrupt the base checkout (its project stays on `main`) — this is the central trap. It MUST note the bookmark and that no push happens in this phase.

#### Scenario: Contract names cwd, native file ops, and the Serena reservation

- **WHEN** `change-context` adopts a verified workspace
- **THEN** it states that cwd is `../<slug>` for CLI/tests, that workspace file ops use the native tools on absolute paths, and that Serena is reserved for base-checkout work to avoid silently editing the wrong checkout, and it notes the bookmark without pushing

