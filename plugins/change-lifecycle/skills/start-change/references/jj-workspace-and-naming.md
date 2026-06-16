# jj workspace + naming mechanics

How the single **slug** turns into a tracking issue, a jj workspace, a bookmark, and (later,
outside this skill) a pull request. Defer exact jj flags and revset edge cases to the
`jj-vcs:jj` skill — this file defines the *conventions* this skill commits to, not jj itself.

## The naming derivation

From one request, derive once:

- **type** — conventional-commit style, matching the repo's commit prefixes:
  - `fix` — repairing broken or unintended behaviour
  - `feat` — a new capability
  - `chore` — refactor, deps, tooling, docs-only
- **slug** — a short kebab-case name from the request (`grey-hues`, `bump-max-pupils`,
  `pupil-bulk-import`). Don't repeat the type in it. Must be valid as a jj workspace name (no
  slashes/spaces), a directory name, and an OpenSpec change-id, because it is reused as all three.

Resulting artifacts:

| Artifact            | Pattern         | Example                | Notes                               |
|---------------------|-----------------|------------------------|-------------------------------------|
| jj workspace name   | `<slug>`        | `bump-max-pupils`      | `--name` cannot contain a slash     |
| workspace directory | `../<slug>`     | `../bump-max-pupils`   | sibling of the main checkout        |
| jj bookmark         | `<type>/<slug>` | `feat/bump-max-pupils` | slash is fine in a bookmark         |
| OpenSpec change-id  | `<slug>`        | `bump-max-pupils`      | only when the OpenSpec gate is true |

The slash lives only in the **bookmark** (`feat/bump-max-pupils`); the workspace name and
directory stay flat. This mirrors conventional-commit prefixes (`feat`/`fix`/`chore`).

## Creating the workspace

Start from a clean main working copy (`jj st` clean; `jj workspace list` to check the slug
isn't taken).

```bash
# new working copy at ../<slug>, based on the current main
jj workspace add --name <slug> --revision main ../<slug>

# reserve the bookmark that will become the PR branch later
jj bookmark create <type>/<slug> --revision @ -R ../<slug>
```

Give the workspace's first/working commit a description that names the issue, e.g.:

```
chore(<slug>): scaffold workspace

Refs <ID>
```

so the issue is discoverable from the commit and, later, from the PR. In no-tracker mode the
slug itself is the identifier; the `Refs` line can be omitted.

## Why the bookmark matters downstream (not this skill's job)

The ship phase (`end-change`) pushes `<type>/<slug>` and opens the PR from it. Because the
bookmark carries the type and slug, and the issue identifier is in the commit/issue, the
eventual PR links back to the issue without extra narration. This skill just *reserves* that
name correctly; it does not push or open anything.

## Teardown / re-runs

- **Idempotent re-run:** if `../<slug>` already exists, reuse it — don't create a second one.
- **Abandoning a kickoff:** `jj workspace forget <slug>`, remove the directory, and delete the
  bookmark if it was never pushed (`jj bookmark delete <type>/<slug>`).
- After background agents that used isolated workspaces finish, forget/remove their `../*` dirs
  so orphaned working copies don't accumulate.

## Quick checklist

1. Picked one `slug` valid as workspace name, dir, and (if needed) change-id.
2. Issue created via the binding (or no-tracker noted); `<type>` matches its type/label; `<ID>` captured.
3. `jj workspace add` at `../<slug>`; bookmark `<type>/<slug>` created; first commit `Refs <ID>`.
4. OpenSpec gate true → proposal authored via the propose skill with change-id `<slug>`, approved.
5. Issue cross-links the workspace path + bookmark; then stop.
