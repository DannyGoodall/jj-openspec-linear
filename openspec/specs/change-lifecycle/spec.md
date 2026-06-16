# change-lifecycle Specification

## Purpose
TBD - created by archiving change tracked-change-lifecycle. Update Purpose after archive.
## Requirements
### Requirement: Slug coordination across workspace, bookmark, and change-id

The lifecycle SHALL use exactly one kebab-case slug per change, and that slug MUST name three coordinated artifacts: the jj workspace directory (`../<slug>`), the jj bookmark (`<type>/<slug>` where `<type>` is one of `fix`, `feat`, `chore`), and the OpenSpec change-id (`<slug>`). The slug MUST be fixed at setup and reused unchanged by every subsequent phase; no phase MAY mint a second slug for the same change.

#### Scenario: One slug names all three artifacts

- **WHEN** a change is set up for an issue with type `feat` and slug `lane-stacking`
- **THEN** the workspace is created at `../lane-stacking`, the bookmark reserved is `feat/lane-stacking`, and the OpenSpec change-id is `lane-stacking`, all derived from that single slug

#### Scenario: Later phases reuse the established slug

- **WHEN** the implement or ship phase runs for an already-set-up change
- **THEN** it resolves the existing `<slug>` workspace, bookmark, and change-id rather than deriving or renaming a new slug

### Requirement: Ship as a reviewed PR, never self-merge

The lifecycle SHALL deliver every change as a pull request that is reviewed after it is opened; no phase MAY merge the PR itself. The ship phase MUST open the PR with bidirectional issue links and then STOP for human review.

#### Scenario: Ship opens a PR and stops

- **WHEN** the ship phase completes pushing the bookmark and opening the PR
- **THEN** the PR is left open with the issue cross-linked in both directions and the skill stops without merging

#### Scenario: No phase merges on the author's behalf

- **WHEN** any lifecycle phase finishes its work
- **THEN** it never invokes a merge of the change's PR, leaving the merge decision to a human reviewer

### Requirement: start-change performs setup only

`start-change` SHALL perform setup only: it MUST consume an existing triage determination (or run the OpenSpec gate itself), create the issue via the issue-tracking binding, create a jj workspace at `../<slug>` based on `main`, reserve the bookmark `<type>/<slug>`, and — ONLY if the OpenSpec gate is true — author the proposal via the OpenSpec propose skill inside the workspace and wait for approval. It MUST cross-link the issue and the workspace, and it MUST stop without implementing tasks or opening a PR.

#### Scenario: Happy-path setup of an OpenSpec change

- **WHEN** `start-change` runs for a new issue whose triage gate is `openspec: yes`
- **THEN** it creates the issue, the `../<slug>` workspace based on `main`, reserves `<type>/<slug>`, authors the proposal in the workspace via the OpenSpec propose skill, cross-links issue and workspace, and stops awaiting proposal approval without implementing or opening a PR

#### Scenario: Reuse an existing issue and workspace

- **WHEN** `start-change` runs for a change whose issue and `../<slug>` workspace already exist
- **THEN** it adopts the existing issue and workspace instead of creating duplicates, and resumes from the appropriate setup step

#### Scenario: Code-only change skips proposal authoring

- **WHEN** `start-change` runs for a change whose gate is `openspec: no`
- **THEN** it creates the issue, workspace, and bookmark but does not author an OpenSpec proposal, and stops

### Requirement: make-change implements within the verified workspace

`make-change` SHALL run `change-context` first to target the workspace, and it MUST refuse to implement if the workspace cannot be verified. Once targeted, it MUST delegate apply mechanics to the OpenSpec apply skill (skipping that delegation for code-only changes), implement `tasks.md` in the workspace, tick completed tasks, and validate with `openspec validate <slug> --strict`. It MUST NOT push, open a PR, or archive.

#### Scenario: Implement an OpenSpec change in its workspace

- **WHEN** `make-change` runs for a verified `../<slug>` workspace holding an approved proposal
- **THEN** it delegates to the OpenSpec apply skill, implements and ticks `tasks.md`, and validates `openspec validate <slug> --strict` without pushing or opening a PR

#### Scenario: Stop when the workspace is unverified

- **WHEN** `make-change` runs but `change-context` cannot verify the target workspace
- **THEN** it stops before implementing anything rather than risk editing the base checkout

#### Scenario: Code-only change skips apply delegation

- **WHEN** `make-change` runs for a code-only change (no OpenSpec proposal)
- **THEN** it implements directly in the workspace and skips the OpenSpec apply delegation

### Requirement: end-change ships from the primary workspace

`end-change` SHALL close out a finished change: confirm the work is ready, finalise a conventional-commit message referencing the issue, point the bookmark at the finished commit FROM THE PRIMARY workspace (jj blocks bookmark ops inside a worker workspace), archive the OpenSpec change in-branch pre-merge so the PR carries code and specs atomically (OpenSpec changes only), `jj git push --bookmark <type>/<slug>` (this jj has no `--allow-new`), open the PR via `gh` with bidirectional issue links, record the PR back to the issue and move it to In Review, verify both links, and STOP without self-merging.

#### Scenario: Ship an OpenSpec change

- **WHEN** `end-change` runs for a verified-ready OpenSpec change
- **THEN** it finalises the commit message referencing the issue, archives the change in-branch, moves the bookmark from the primary workspace, pushes the bookmark, opens the PR with bidirectional links, moves the issue to In Review, verifies both links, and stops without merging

#### Scenario: Idempotent re-push

- **WHEN** `end-change` runs again for a change whose bookmark is already pushed and PR already open
- **THEN** it re-points and re-pushes the bookmark without error and reconciles the existing PR and links rather than opening a duplicate PR

### Requirement: teardown-change is a guarded destructive cleanup

`teardown-change` SHALL remove a shipped change's workspace, bookmark, and directory only after a safety assessment (PR merged? bookmark pushed and current? uncommitted or untracked files present?) and a MANDATORY multiple-choice confirmation gate. On confirmation it MUST run `jj workspace forget <slug>`, `rm -rf ../<slug>`, and `jj bookmark delete <type>/<slug>` FROM THE PRIMARY workspace, and it MUST be honest that committed work is recoverable via `jj op log` while untracked files are not. It removes only; it does not start the next change.

#### Scenario: Teardown after a merged, pushed change

- **WHEN** `teardown-change` runs for a change whose PR is merged and bookmark is pushed and current, with no uncommitted or untracked files
- **THEN** it presents the confirmation gate, and on confirmation forgets the workspace, removes `../<slug>`, and deletes the bookmark from the primary workspace

#### Scenario: Gate blocks teardown when the change is unmerged

- **WHEN** `teardown-change` runs and the safety assessment finds the PR is not yet merged
- **THEN** it surfaces the unmerged state in the confirmation gate and does not run any destructive command unless the human explicitly overrides

