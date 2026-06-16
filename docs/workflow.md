# Workflow — driving a change end to end

A tracked change moves through distinct, **human-paced** phases. Each phase is a
skill (see [features.md](features.md)); each does its job and stops, handing a
well-defined state to the next. Nothing is auto-merged, and nothing destructive
runs without a confirmation gate.

```text
triage-change → start-change → make-change → end-change → (human merge) → teardown-change
                                    ▲
                             change-context
```

## The path

| # | Phase | Skill | Outcome |
|---|-------|-------|---------|
| 1 | **Triage** | `triage-change` | A determination: type, slug, OpenSpec gate, impacted specs, fix-sketch, label. No code, no workspace. |
| 2 | **Start** | `start-change` | Issue created, `../<slug>` workspace based on `main`, `<type>/<slug>` bookmark reserved, OpenSpec proposal authored + approved (only if the gate is `yes`). Setup only. |
| 3 | **Make** | `make-change` (composes `change-context`) | Workspace verified, `tasks.md` implemented and ticked, `openspec validate <slug> --strict` green. No push, no PR. |
| 4 | **End** | `end-change` | OpenSpec change archived in-branch, bookmark pushed from the primary workspace, PR opened with bidirectional issue links, issue moved to In Review. Stops — no merge. |
| — | **Merge** | _human_ | A reviewer merges the PR. The lifecycle never self-merges. |
| 5 | **Teardown** | `teardown-change` | After merge: safety assessment + mandatory confirmation gate, then workspace/bookmark/directory removed from the primary workspace. |

`change-context` is not a numbered phase — it is the primitive that points the
agent at the workspace. `make-change` runs it first; you can also run it directly
to re-focus a fresh session on a change someone else set up.

### Why "ship, not merge"

`end-change` opens the PR with both-direction issue links and then **stops**. The
merge is a human decision made on the open PR. This is the lifecycle's invariant:
no phase ever merges the change's PR on the author's behalf. `teardown-change` is
the only phase that runs after merge, and it is gated.

### Bookmark ops run from the primary workspace

This jj guards against moving or deleting bookmarks inside a worker workspace and
has no `--allow-new`. So both `end-change` (point + push the bookmark) and
`teardown-change` (delete the bookmark) perform bookmark operations **from the
primary workspace**, not from inside `../<slug>`.

## The OpenSpec gate

Not every change needs a formal proposal. The gate is one honest question, asked
during triage and re-checked at start:

> **After this change lands, would any written specification or design have to
> change?**

- **Yes → `openspec: yes`.** The change is governed by an OpenSpec proposal.
  `start-change` authors it in the workspace and waits for approval; `make-change`
  delegates apply mechanics to the OpenSpec apply skill; `end-change` archives the
  change in-branch so the PR carries code **and** the updated specs together.
- **No → `openspec: no`.** A code-only change that leaves specs and code in sync.
  `start-change` skips proposal authoring; `make-change` implements directly and
  skips the apply delegation; `end-change` skips the archive step.

The gate is about the **contract**, not the size of the diff. A one-line bug fix
whose correct behaviour **contradicts a written requirement** is `openspec: yes`,
because resolving it changes the written contract — and the contradicted
requirement is listed among the impacted specs. A large refactor that leaves every
requirement still accurate is `openspec: no`.

## Slug coordination

One kebab-case **slug** is fixed at `start-change` and names three artifacts for
the life of the change. No later phase mints a second slug; they all resolve the
existing one.

```text
slug = lane-stacking, type = feat
  ├─ workspace directory   ../lane-stacking
  ├─ jj bookmark           feat/lane-stacking      (type ∈ fix | feat | chore)
  └─ OpenSpec change-id    lane-stacking
```

This is what keeps the issue, the workspace, the branch, and the eventual PR
coordinated end to end. Because the bookmark name `feat/lane-stacking` carries **no
issue identifier**, the issue↔PR link is wired explicitly by `end-change` rather
than auto-derived — see [issue-tracker.md](issue-tracker.md) and
[github-proposals.md](github-proposals.md).

## Delegation boundaries

The lifecycle skills orchestrate; they do not reimplement the tools they stand on:

| Concern | Delegated to |
|---------|--------------|
| All jj mechanics | the `jj-vcs` plugin (`jj-vcs:jj`) — a hard prerequisite |
| Proposal authoring | the OpenSpec propose skill |
| Apply mechanics | the OpenSpec apply skill |
| Issue create/read/label/link | the issue-tracking binding (Linear MCP / `gh` / none) |
| PR open + links | `gh` |

If the `jj-vcs:jj` capability is absent, a lifecycle skill stops immediately with a
message to install the `jj-vcs` plugin rather than running raw jj.

## Related docs

- [features.md](features.md) — per-skill scope and "does NOT do" boundaries.
- [optional-components.md](optional-components.md) — how the path behaves with or
  without Linear.
- [example-prompts.md](example-prompts.md) — phrasings that trigger each phase.
- [../README.md](../README.md) — install and quickstart.
