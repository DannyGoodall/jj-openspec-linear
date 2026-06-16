# change-triage

## ADDED Requirements

### Requirement: Produce a triage determination for one issue

`triage-change` SHALL perform deep technical triage of a SINGLE issue and produce a determination containing the issue, a conventional-commit type (`fix` | `feat` | `chore`), a proposed kebab-case slug, the OpenSpec gate result (`openspec: yes | no`), the impacted specs, a fix-sketch, a confidence, and a label. It MUST read code by symbol and specs by grep. It understands the change only; it MUST NOT fix it or create a workspace.

#### Scenario: Triage yields a complete determination

- **WHEN** `triage-change` triages an issue describing a defect
- **THEN** it reads the governing specs and code and returns a determination with type, slug, OpenSpec gate result, impacted specs, fix-sketch, confidence, and label, without writing a fix or creating a workspace

### Requirement: Run the OpenSpec gate honestly

`triage-change` SHALL set the OpenSpec gate by asking whether, after this change, the specs or design would have to change. A Bug whose fix contradicts a written requirement MUST be gated `openspec: yes` even though it is "a bug fix", because resolving it changes the written contract. A change that leaves specs and code in sync MUST be gated `openspec: no`.

#### Scenario: Bug that contradicts a written requirement is openspec:yes

- **WHEN** `triage-change` triages a Bug whose correct fix contradicts an existing written requirement
- **THEN** it gates the determination `openspec: yes` and lists the contradicted requirement among the impacted specs

#### Scenario: Code-only fix that keeps specs in sync is openspec:no

- **WHEN** `triage-change` triages a defect whose fix aligns the code with the existing requirements
- **THEN** it gates the determination `openspec: no`

### Requirement: Decide the triage label

`triage-change` SHALL choose exactly one canonical label for the determination: `ready-for-agent`, `ready-for-human`, or `needs-info`, and apply it via the issue-tracking binding as the final step.

#### Scenario: Clear, well-scoped change is labelled ready-for-agent

- **WHEN** `triage-change` produces a high-confidence determination with a clear fix-sketch
- **THEN** it labels the issue `ready-for-agent` via the issue-tracking binding

### Requirement: Short-circuit when information is missing

`triage-change` SHALL short-circuit when the issue lacks the information needed to determine the fix: it MUST stop, record what is missing, and label the issue `needs-info` rather than guessing a type, slug, or gate result.

#### Scenario: Missing reproduction details short-circuits to needs-info

- **WHEN** `triage-change` triages an issue that lacks the detail needed to scope the fix
- **THEN** it stops, records the missing information, and labels the issue `needs-info` without proposing a slug or gate result

### Requirement: Idempotent re-triage

`triage-change` SHALL be idempotent: re-triaging the same issue MUST update the existing determination in place rather than creating a duplicate, reconciling any changed type, slug, gate, or label.

#### Scenario: Re-triage updates the existing determination

- **WHEN** `triage-change` runs again on an issue it has already triaged
- **THEN** it updates the same determination and label in place rather than appending a second determination
