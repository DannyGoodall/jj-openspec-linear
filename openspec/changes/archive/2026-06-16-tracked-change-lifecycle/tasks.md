# Tasks — tracked-change-lifecycle

> Issue-tracker specifics (create/read/label/link/move) come from the `optional-issue-tracker-binding` change (capability `issue-tracking`); these tasks reference the tracker abstractly.

## 1. triage-change skill

- [x] 1.1 Author `skills/triage-change/SKILL.md`: single-issue deep triage producing the determination {issue, type, slug, openspec, impacted-specs, fix-sketch, confidence, label}; read code by symbol, specs by grep; understand-only (no fix, no workspace).
- [x] 1.2 Specify the OpenSpec gate logic in `references/determination-and-labels.md` (gate + label rule): "would specs/design have to change after this?"; a Bug contradicting a written requirement is `openspec: yes`.
- [x] 1.3 Specify labelling + needs-info short-circuit + idempotent re-triage in `references/determination-and-labels.md`; label applied via the issue-tracking binding.

## 2. start-change skill

- [x] 2.1 Author `skills/start-change/SKILL.md`: setup-only; consume triage determination or run the gate; create issue, `../<slug>` workspace from `main`, reserve `<type>/<slug>`; OpenSpec gate true → author proposal via OpenSpec propose skill in-workspace and wait for approval; cross-link issue↔workspace; stop.
- [x] 2.2 Specify reuse of an existing issue/workspace and the code-only (no-proposal) path in `references/jj-workspace-and-naming.md`.

## 3. change-context skill

- [x] 3.1 Author `skills/change-context/SKILL.md`: resolve `../<slug>` from issue or slug; verify (jj root ends in slug; `openspec list` shows change); load context; state + hold the working contract; SETS context only.
- [x] 3.2 Specify the working contract in `references/resolving-and-contract.md`: cwd=`../<slug>` for CLI/tests; native file ops on absolute paths; Serena reserved for base-checkout (central trap); bookmark noted, no push.

## 4. make-change skill

- [x] 4.1 Author `skills/make-change/SKILL.md`: run `change-context` first (refuse if unverified); delegate apply to the OpenSpec apply skill (skip for code-only); implement + tick `tasks.md`; validate `openspec validate <slug> --strict`; no push/PR/archive.
- [x] 4.2 Specify the unverified-workspace guard and code-only skip in `references/workspace-retargeting.md`.

## 5. end-change skill

- [x] 5.1 Author `skills/end-change/SKILL.md`: confirm ready; finalise conventional-commit msg referencing the issue; move bookmark from the PRIMARY workspace; archive OpenSpec change in-branch pre-merge (OpenSpec only); `jj git push --bookmark <type>/<slug>` (no `--allow-new`); open PR via `gh` with bidirectional links; record PR to issue + move to In Review; verify both links; stop (no self-merge).
- [x] 5.2 Specify idempotent re-push / existing-PR reconciliation in `references/jj-to-pr-and-linking.md`.

## 6. teardown-change skill

- [x] 6.1 Author `skills/teardown-change/SKILL.md`: resolve from issue/slug; safety assessment (PR merged? bookmark pushed & current? uncommitted/untracked?); mandatory multiple-choice confirmation gate; on confirm `jj workspace forget` + `rm -rf ../<slug>` + `jj bookmark delete` from PRIMARY; honest recoverability (commits via `jj op log`, untracked not); remove only.
- [x] 6.2 Specify the unmerged-blocks gate behaviour in `references/safety-and-recovery.md`.

## 7. Cross-cutting

- [x] 7.1 Document slug-coordination (one slug → workspace dir + `<type>/<slug>` bookmark + change-id) and ship-not-merge as shared invariants referenced by all phase skills.
- [x] 7.2 Document the delegation boundaries (jj→`jj-vcs:jj`, proposal→OpenSpec propose, apply→OpenSpec apply, issues→`issue-tracking` binding, PR→`gh`) in the plugin overview.
