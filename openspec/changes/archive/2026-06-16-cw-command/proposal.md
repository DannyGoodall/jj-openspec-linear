> Tracking: #3 · change-id `cw-command` · bookmark `feat/cw-command` · workspace `../cw-command`

## Why

`start-change` creates a jj workspace at `../<slug>`, but `jj workspace add` copies only
**tracked** files — gitignored essentials (`.env`, `.env.local`, …) are absent, and there is
no quick way to `cd` into the workspace to work on it. The original AlwaysRespondPoints repo
solved this with a `cw` zsh function plus a Bun `workspace.ts`, but that hard-requires the Bun
runtime, which a non-JS project may not have. The plugin needs the same convenience, made
**runtime-agnostic**.

## What Changes

- Add a **pure POSIX-shell** `cw` helper (zsh + bash, no Bun/Node) bundled with the plugin:
  - `cw <slug>` — `cd` to the sibling workspace `../<slug>`, resolved from `jj workspace root`.
  - `cw <slug> --hydrate` — copy `.worktreeinclude` glob matches from the primary checkout into
    the workspace (`cp`/`rsync`), so gitignored essentials are present.
  - `cw <slug> --dev` — hydrate, free a configured port, then run a **project-declared** dev
    command; when none is declared, degrade to hydrate + a hint (never hardcode a runtime).
- Define the workspace config: `.worktreeinclude` (copy-pattern lines) plus optional `dev` /
  `port` directives that declare the dev command and port.
- Deliver the helper via a **stable sourced path**: bundle `cw.sh`, install it (copy/symlink)
  to a stable location, add one `source` line to the user's shell rc. The plugin cache path is
  version-specific, so the helper is never sourced from it directly.
- `start-change` scaffolds a `.worktreeinclude` when one is absent, so hydration works the
  first time.

## Capabilities

### New Capabilities
- `workspace-shell-tool`: a runtime-free shell helper to enter a change's jj workspace, hydrate
  gitignored files from the primary, and boot a project-declared dev command, plus its config
  file and install delivery.

### Modified Capabilities
<!-- None: the .worktreeinclude scaffolding is owned by this new capability; start-change's
     existing requirements are unchanged in wording, it simply invokes the scaffold. -->

## Impact

- New bundled assets: `plugins/change-lifecycle/scripts/cw.sh` and an install/setup path.
- New skill or doc covering install + usage; `change-context` / `start-change` reference `cw`.
- Consuming repos gain a `.worktreeinclude` (and optional dev/port directives). No runtime
  dependency added. Affects no existing spec wording.
