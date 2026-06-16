# Design — tracked-change-lifecycle

## Context

The `change-lifecycle` plugin packages a tracked, human-paced code-change lifecycle on Jujutsu (jj) workspaces plus OpenSpec proposals plus an optional issue tracker. The behaviour already exists as a loose family of skills (`triage-change`, `start-change`, `change-context`, `make-change`, `end-change`, `teardown-change`) whose discipline is proven in practice but never written down as a contract. This change re-specs that family as three capabilities so the guards are explicit and the per-skill mechanics stop being re-derived ad hoc. The hard prerequisite is the `jj-vcs` plugin (`jj-vcs:jj` skill); the issue tracker is optional and bound separately.

## Goals / Non-Goals

**Goals**

- Capture the four lifecycle phases (setup → implement → ship → teardown) and the two supporting primitives (workspace context, triage) as requirements with happy-path and guard scenarios.
- Pin the cross-cutting invariants: one slug names workspace + bookmark + change-id; changes ship as reviewed PRs and are never self-merged.
- Make the dangerous edges explicit: unverified workspace blocks implement; unmerged change blocks teardown; bookmark ops only from the primary workspace; Serena reserved for base.

**Non-Goals**

- The concrete issue-tracker binding (Linear MCP vs `gh` Issues, detection, field mapping). That is the separate `optional-issue-tracker-binding` change (capability `issue-tracking`); here we refer to "the issue tracker" abstractly.
- jj command mechanics — delegated to `jj-vcs:jj`.
- Implementing the skills — this change is artifacts only.

## Decisions

- **jj workspaces for isolation.** Each change lives in its own jj workspace at `../<slug>` based on `main`, so concurrent changes never collide and the base checkout stays clean. This is why `change-context` exists as a targeting primitive — the agent must be pointed at the workspace, not the base.
- **Native tools in the workspace; Serena reserved for base (the central trap).** `openspec` resolves by cwd, and Serena's project stays pinned to `main` (the `claude-code` integration excludes `activate_project`). If Serena's edit tools run while "in" a workspace, they silently edit the base checkout instead — corrupting `main` with no error. Therefore all workspace file ops use the native Read/Edit/Write/Grep/Glob on absolute `../<slug>/` paths, and Serena is reserved for base-checkout work only. `make-change` exists primarily to prevent this bug by running `change-context` first.
- **One slug as the single name.** A single kebab-case slug names the workspace dir, the `<type>/<slug>` bookmark, and the OpenSpec change-id, keeping issue, workspace, branch, and PR coordinated end to end.
- **Delegation boundaries.** jj mechanics → `jj-vcs:jj`; proposal authoring → the OpenSpec propose skill; apply mechanics → the OpenSpec apply skill; issue create/read/label/link → the `issue-tracking` binding; PR open + links → `gh`. The lifecycle skills orchestrate; they do not reimplement these.
- **Ship-not-merge.** `end-change` opens the PR with bidirectional links and stops; merge is a human decision. `teardown-change` only runs after merge, behind a mandatory confirmation gate.
- **Bookmark ops from the primary workspace.** This jj guards against moving/deleting bookmarks inside a worker workspace and has no `--allow-new`, so `end-change` and `teardown-change` perform bookmark operations from the primary workspace.
- **Dropping `use-linear`.** The monolithic `use-linear` flow is superseded by this phased lifecycle plus the separate issue-tracking binding; we do not re-spec it here.

## Risks / Trade-offs

- **Serena-wrong-checkout corruption** — highest-impact risk; mitigated by the `workspace-context` verification requirement and the explicit Serena-reservation contract, plus `make-change` refusing to implement an unverified workspace.
- **Destructive teardown** — losing untracked files is unrecoverable; mitigated by the safety assessment + mandatory multiple-choice confirmation gate and honest recoverability messaging (commits via `jj op log`, untracked files not).
- **Abstract tracker coupling** — referring to "the issue tracker" abstractly trades some concreteness for clean separation from `optional-issue-tracker-binding`; acceptable because the binding owns those details.
- **Phase overlap drift** — six skills with adjacent responsibilities risk re-derivation; mitigated by spec'ing each phase's "does NOT" boundary (setup does not implement, implement does not push, ship does not merge, teardown does not start the next change).
