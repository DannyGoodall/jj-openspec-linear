## Context

The original `cw` (AlwaysRespondPoints) split the work: a sourced zsh function did the `cd`,
and a Bun `workspace.ts` did hydrate + dev. jj workspaces are real sibling directories sharing
one repo, but `jj workspace add` copies only **tracked** files, so gitignored essentials
(`.env`, `node_modules`) are missing — hence hydration. The plugin must offer the same
ergonomics without assuming a JavaScript runtime, because it can be installed in non-JS repos.

## Goals / Non-Goals

**Goals:**
- One sourced shell function `cw` providing `enter`, `--hydrate`, and `--dev`.
- Zero language-runtime dependency (pure zsh/bash + standard tools: `cp`/`rsync`, `lsof`).
- A stack-agnostic `--dev` that runs a project-declared command, not a baked-in one.
- A delivery model that survives plugin version bumps.

**Non-Goals:**
- Reimplementing `jj workspace add` / bookmark creation (that stays in `start-change`).
- Bundling any project's dev server or package manager.
- Auto-editing the user's shell rc (the plugin documents the one `source` line).

## Decisions

- **Pure POSIX shell over Bun.** Entry must be a sourced function regardless (a subprocess
  cannot change the parent cwd). Hydration is just glob-expand-and-copy, which shell does with
  `cp`/`rsync`; the Bun `Glob`/`cpSync` bought nothing for env-file patterns. Dropping Bun makes
  the tool universal. _Alternative considered:_ shell core + optional runtime helper — rejected
  as needless complexity for no portable gain.
- **`--dev` runs a declared command, with graceful degradation.** Generic prep (cd, hydrate,
  free port, exec) is worth one keystroke, but only if the command is declared per-project; a
  hardcoded `bun run dev` does not generalize. With nothing declared, `--dev` hydrates and hints.
  _Alternative considered:_ drop `dev` entirely — rejected because the configured one-keystroke
  boot is a real ergonomic win; a JS default was also considered and rejected to keep behaviour
  predictable and runtime-neutral.
- **Config lives in `.worktreeinclude`.** Reuse the existing file: copy-pattern lines stay as-is;
  add optional `dev:` and `port:` directive lines so there is one place to look. Keeps the config
  surface tiny and avoids a second dotfile. _Alternative considered:_ a separate `.worktree.toml`
  — rejected to avoid a parser/format dependency.
- **Stable-path delivery, not cache-sourcing.** The plugin cache path is
  `…/cache/<marketplace>/<plugin>/<version>/…` and changes on every update, so a `source` line
  pointing at it would break. The install step copies/symlinks `cw.sh` to a stable location
  (e.g. `~/.local/share/change-lifecycle/cw.sh`); the user sources that. Re-running install after
  an update refreshes the copy without touching the rc. _Alternative considered:_ print-to-paste
  — rejected (no single source of truth, manual to update).
- **`start-change` scaffolds `.worktreeinclude`.** So hydration works the first time; an existing
  file is never overwritten. Owned by this capability (the include file is its concern), so no
  existing spec wording changes.

## Risks / Trade-offs

- **Glob semantics differ between shells/tools.** → Keep patterns simple (paths and `*`), set
  nullglob per-shell so non-matches vanish, test under both zsh and bash, and copy with `cp -R`
  (universally available — no rsync dependency, consistent with the zero-runtime goal).
- **Port-freeing uses `lsof`/`kill`, which may be absent or need care.** → Guard on `lsof`
  availability; skip with a note rather than failing the dev boot.
- **Users must do a one-time install + rc edit.** → Document a single copy/symlink + `source`
  line; make the install step idempotent and re-runnable after updates.
- **A declared dev command is arbitrary shell the user trusts.** → It comes from the repo's own
  `.worktreeinclude`, same trust boundary as any repo script; the helper does not fetch it.

## Open Questions

- Exact stable install path and whether to offer `~/.local/bin` symlink vs a sourced file.
- Whether `--dev` should background the server or run in the foreground (foreground matches the
  original; backgrounding could be a later flag).
