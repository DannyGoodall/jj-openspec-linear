# Features — the lifecycle skills

The `change-lifecycle` plugin ships six skills. Five form the linear path of a
tracked change; `change-context` is the supporting primitive the others compose.
Each skill has a deliberately narrow scope — the "does NOT do" line is as
load-bearing as the "does" line, because it is what keeps adjacent phases from
re-deriving each other's work.

See [workflow.md](workflow.md) for how they connect end to end, and
[example-prompts.md](example-prompts.md) for the phrasings that trigger them.

---

## `triage-change`

**Does.** Deep technical triage of a SINGLE issue. Reads the issue, the governing
OpenSpec specs, and the code (code by symbol, specs by grep), then produces a
determination: a conventional-commit **type** (`fix` / `feat` / `chore`), a
proposed kebab-case **slug**, the **OpenSpec gate** result (`openspec: yes | no`),
the impacted specs, a fix-sketch, a confidence, and a canonical triage **label**
(`ready-for-agent` / `ready-for-human` / `needs-info`). It runs the OpenSpec gate
honestly — a bug fix that contradicts a written requirement is gated `openspec:
yes` because resolving it changes the contract. It short-circuits to `needs-info`
when the issue lacks the detail to scope a fix, and it is idempotent: re-triaging
updates the existing determination in place. Applies the label via the active
issue-tracking binding as its final step.

**Does NOT.** Fix the change. Create a workspace. Mint anything downstream.

**Hands off to.** `start-change`, which consumes the determination (type, slug,
gate).

---

## `start-change`

**Does.** Setup only. Consumes an existing triage determination (or runs the
OpenSpec gate itself), creates the issue via the issue-tracking binding, creates a
jj workspace at `../<slug>` based on `main`, reserves the bookmark `<type>/<slug>`,
and — **only if the OpenSpec gate is true** — authors the proposal inside the
workspace via the OpenSpec propose skill and waits for approval. Cross-links the
issue and the workspace.

**Does NOT.** Implement tasks. Open a PR. For a code-only change (`openspec: no`)
it creates the issue, workspace, and bookmark but authors no proposal.

**Hands off to.** `make-change`, which implements inside the workspace it created.

---

## `make-change`

**Does.** Implements within the verified workspace. Runs `change-context` FIRST to
target the workspace, and **refuses to implement if the workspace cannot be
verified** (the central guard — see `change-context` below). Once targeted, it
delegates apply mechanics to the OpenSpec apply skill (skipped for code-only
changes), implements `tasks.md`, ticks completed tasks, and validates with
`openspec validate <slug> --strict`.

**Does NOT.** Push. Open a PR. Archive the change. Re-derive the design (that was
`start-change`).

**Hands off to.** `end-change`, which ships the finished work.

---

## `end-change`

**Does.** Ships from the **primary** workspace. Confirms the work is ready,
finalises a conventional-commit message referencing the issue, **archives the
OpenSpec change in-branch pre-merge** so the PR carries code and specs atomically
(OpenSpec changes only), points the bookmark at the finished commit **from the
primary workspace** (jj blocks bookmark ops inside a worker workspace),
`jj git push --bookmark <type>/<slug>` (this jj has no `--allow-new`), opens the PR
via `gh` with bidirectional issue links, records the PR back to the issue, moves
the issue to **In Review**, and verifies both links. Idempotent: re-running
re-points and re-pushes the bookmark and reconciles the existing PR rather than
opening a duplicate.

**Does NOT.** Write implementation code. **Merge the PR** — it stops and leaves the
merge decision to a human reviewer.

**Hands off to.** A human reviewer, then (after merge) `teardown-change`.

---

## `teardown-change`

**Does.** Guarded destructive cleanup, run AFTER the PR has merged. Runs a safety
assessment (Is the PR merged? Is the bookmark pushed and current? Are there
uncommitted or untracked files that would be lost?), then a **mandatory
multiple-choice confirmation gate**. On confirmation it runs
`jj workspace forget <slug>`, `rm -rf ../<slug>`, and
`jj bookmark delete <type>/<slug>` **from the primary workspace**, and is honest
that committed work is recoverable via `jj op log` while untracked files are not.

**Does NOT.** Merge anything. Start the next change. Remove anything before the
confirmation gate passes.

**Hands off to.** Nothing — the change is done. Start the next one with
`start-change`.

---

## `change-context`

The "enter the workspace" primitive. `make-change` composes it, and you can invoke
it directly to re-focus a session.

**Does.** Resolves a change's jj workspace from **either an issue reference or a
slug** to `../<slug>` (from an issue it derives the recorded slug via the
issue-tracking binding; from a slug it uses it directly). **Verifies** the
workspace before adopting it — the jj workspace root must end in `<slug>` and
`openspec list` (run with the workspace as cwd) must show the change; if
verification fails it stops and reports. On success it **loads the context** (an
OpenSpec change's proposal/`tasks.md`/`design.md`, or a code-only change's issue
body) and **states and holds the working contract** for the rest of the session:

- cwd is `../<slug>` for all `openspec`, test, and dev commands;
- all workspace file operations use the **native** Read/Edit/Write/Grep/Glob tools
  on absolute `../<slug>/` paths;
- **Serena is reserved for base-checkout work** — its project stays pinned to
  `main`, so its edit tools would silently corrupt the base checkout if run while
  "in" a workspace. This is the central trap, and the reason `make-change` runs
  `change-context` first.

It notes the bookmark and that no push happens in this phase.

**Does NOT.** Implement, push, or open a PR — it only SETS context.

**Hands off to.** Whatever work follows in the same session (typically the
implement step of `make-change`).

## `cw` (workspace shell helper)

Not a skill — a bundled **pure-shell** function (zsh + bash, no language runtime) for the
human terminal side of a change. While `change-context` re-points *Claude* at a workspace,
`cw` re-points *your shell*.

**Does.** `cw <slug>` `cd`s to the sibling workspace `../<slug>` (resolved from `jj workspace
root`; clear errors if it's missing or you're not in a jj workspace — `cd` works only because
the helper is *sourced*). `cw <slug> --hydrate` copies `.worktreeinclude` matches (e.g. `.env`,
`.env.local`) from the primary into the workspace, because `jj workspace add` copies only
*tracked* files. `cw <slug> --dev [--port N]` hydrates, frees the configured port, then runs the
project's declared `dev:` command — degrading to hydrate + a hint when none is declared, so it
never assumes a runtime.

**Config.** `.worktreeinclude` at the repo root: copy-pattern lines plus optional `dev:` /
`port:` directives. `start-change` scaffolds a starter one when absent.

**Install.** `bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-cw.sh"` copies `cw.sh` to a stable
path; add the printed `source` line to your shell rc once. See
[../plugins/change-lifecycle/references/cw-helper.md](../plugins/change-lifecycle/references/cw-helper.md).
