# `cw` — the workspace shell helper

`cw` is a sourced shell function (zsh + bash, **no language runtime**) for working inside a
change's jj workspace created by `start-change`. It does three things:

- **enter** — `cw <slug>` changes directory to the sibling workspace `../<slug>`.
- **hydrate** — `cw <slug> --hydrate` copies gitignored essentials the workspace is missing
  (jj only copies *tracked* files into a new workspace).
- **dev** — `cw <slug> --dev [--port N]` hydrates, frees the port, and runs the project's
  declared dev command.

## Install (one time)

The plugin bundles `cw.sh`. Don't source it from the plugin cache — that path changes on every
update. Install it to a stable path with the bundled installer:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-cw.sh"     # → ~/.local/share/change-lifecycle/cw.sh
```

Then add the printed line to your `~/.zshrc` or `~/.bashrc` and restart the shell:

```bash
source "$HOME/.local/share/change-lifecycle/cw.sh"
```

Re-run the installer after a plugin update; the `source` line never changes.

## Usage

```bash
cw bump-max-pupils              # cd to ../bump-max-pupils
cw bump-max-pupils --hydrate    # + copy .worktreeinclude matches from the primary
cw bump-max-pupils --dev        # + free the port, run the declared dev command
cw bump-max-pupils --dev --port 3000
```

`cd` only works because `cw` is *sourced* (a subprocess can't change the parent shell's cwd).

## Config — `.worktreeinclude` (repo root)

Newline-separated. Copy-pattern lines list gitignored paths (globs allowed) to carry from the
primary into the workspace. Blank lines and `#` comments are ignored. Optional `dev:` and
`port:` directives declare the dev command and port:

```
# gitignored essentials to carry into each workspace
.env
.env.local
config/*.local.json

# optional: what `cw <slug> --dev` runs
dev: bun run dev
port: 5173
```

- The command after `dev:` is arbitrary shell run **in the workspace** — any stack
  (`npm run dev`, `make serve`, `cargo run`, `bun install && bun run dev`, …).
- If no `dev:` is declared, `--dev` hydrates and prints a hint rather than assuming a runtime.
- `start-change` scaffolds a starter `.worktreeinclude` when a repo doesn't have one; an
  existing file is never overwritten.
