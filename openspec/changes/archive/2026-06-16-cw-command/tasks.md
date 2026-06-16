## 1. Shell helper core (`cw.sh`)

- [x] 1.1 Create `plugins/change-lifecycle/scripts/cw.sh` defining a sourced `cw` function (zsh + bash compatible).
- [x] 1.2 Implement entry: resolve `jj workspace root`, compute `../<slug>`, `cd` there; error clearly if missing or not in a jj workspace.
- [x] 1.3 Implement `--hydrate`: read `.worktreeinclude` from the primary, expand each copy pattern, copy matches into the workspace with `cp -R` (universally available, no rsync dependency), overwrite, note skipped patterns.
- [x] 1.4 Implement `--dev`: hydrate, free the configured port (guard on `lsof`), then exec the declared dev command; degrade to hydrate + hint when none declared.
- [x] 1.5 Implement `--port N` override and usage/help output.

## 2. Config format

- [x] 2.1 Parse `.worktreeinclude` copy patterns (ignore blanks and `#` comments).
- [x] 2.2 Parse optional `dev:` and `port:` directive lines; keep them unambiguous from copy patterns.
- [x] 2.3 Document the format (patterns + directives) with an example.

## 3. Delivery + install

- [x] 3.1 Add an install step that copies/symlinks `cw.sh` to a stable path (e.g. `~/.local/share/change-lifecycle/cw.sh`).
- [x] 3.2 Make install idempotent and re-runnable after a plugin version bump.
- [x] 3.3 Document the single `source` line the user adds to their shell rc (pointing at the stable path, never the plugin cache).

## 4. start-change scaffolding

- [x] 4.1 Update the `start-change` skill to scaffold a starter `.worktreeinclude` when absent, leaving an existing one untouched.

## 5. Docs + discoverability

- [x] 5.1 Add a skill or doc covering `cw` install + usage (`enter` / `--hydrate` / `--dev`).
- [x] 5.2 Reference `cw` from `change-context` and `start-change` (how to enter/hydrate the workspace).
- [x] 5.3 Note `cw` in the plugin README and the relevant `docs/` pages.

## 6. Verify

- [x] 6.1 Manually verify entry, hydrate (env files copied), and dev (configured command + degrade path) under zsh and bash.
- [x] 6.2 Run `openspec validate cw-command --strict` and confirm it passes.
