# Workspace retargeting + verify checklist

`make-change` runs in the **same** (base-rooted) agent session and points every tool at the
change's jj workspace. This file is the precise mechanics. The governing fact: nothing
auto-targets the workspace, and one tool (Serena) mis-targets *silently*.

## Why same-session works (and where it bites)

A jj workspace is a real sibling directory sharing one repo. The agent can edit and run commands
in it from a base-rooted session — but each tool resolves its target differently:

| Tool | Resolves against | Risk if not retargeted |
|---|---|---|
| `openspec`, `bun`, tests | the shell's **cwd** | loud failure ("change not found") — safe |
| Read / Edit / Write | the **absolute path** you pass | wrong only if you pass a base path by habit |
| **Serena** symbol tools | Serena's **active project** (base) | **silent** — edits land in base `src/`, not the workspace |

So targeting = (a) set cwd per command, (b) pass absolute workspace paths, (c) keep Serena **off
workspace files** (below). `change-context` establishes (a)–(c) as the session's working contract;
`make-change` runs it first rather than restating the mechanics.

## Serena: not used for workspace files

Serena's active project is the base checkout, and the `claude-code` context **excludes
`activate_project`** (it can't be re-pointed; only `restart_language_server` is an includable
optional tool). We stay single-agent, so Serena is **not used for workspace files** — its *edit*
tools would write to the **base** checkout (the silent wrong-checkout bug) and its *reads* of files
you've edited go stale. In a workspace, do all file work with Claude Code's native
**Read/Edit/Write/Grep/Glob** on absolute `../<slug>/` paths; reserve Serena for base-checkout
tasks, and re-activate it on base before finishing.

## cwd mechanics (same session)

The shell resets cwd to the base between tool calls, so set it on every command:

```bash
cd ../<slug> && openspec list
cd ../<slug> && openspec validate <slug> --strict
```

Prefer absolute paths over compound `cd` where a tool supports a directory flag.

## Verify-before-touch checklist

1. `../<slug>` exists and `jj workspace root` (run there) ends in `<slug>`.
2. `cd ../<slug> && openspec list` shows `<slug>` (the change is really here).
3. Use the native tools (`Read`/`Edit`/`Write`/`Grep`/`Glob`) for all workspace file ops — not
   Serena. Only then begin implementing.

## Done checklist

1. `tasks.md` fully ticked; implementation matches the approved proposal.
2. `cd ../<slug> && openspec validate <slug> --strict` passes.
3. Targeted tests written (full suite deferred to the PR per project convention).
4. Serena re-activated on base; stopped — handed to `end-change` (no push / PR / archive here).
