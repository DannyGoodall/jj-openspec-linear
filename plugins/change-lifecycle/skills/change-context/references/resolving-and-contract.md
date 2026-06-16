# Resolving a workspace + the working contract

The canonical "enter a jj workspace" detail for `change-context` (and, by composition, `make-change`).

## Issue → workspace

`start-change` and `end-change` post a cross-link comment on the issue recording the workspace path,
bookmark, and OpenSpec change-id. Resolve the issue-tracking binding first (Linear / GitHub / none —
see `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md`), then:

1. Read the issue + its comments via the binding (Linear `get_issue` + `list_comments`; GitHub
   `gh issue view --comments`).
2. Find the `start-change` / `end-change` cross-link comment; read:
   - **jj workspace:** `../<slug>`
   - **jj bookmark:** `<type>/<slug>`
   - **OpenSpec change-id:** `<slug>` (if any)
3. If there's no such comment, the issue may not have been through `start-change` — infer the slug
   from the title and check `../<slug>`, but **confirm with the user** before adopting; don't guess.

A **slug argument** skips all this: the workspace is the sibling `../<slug>` directly, no tracker lookup.

## Verify before adopting

```bash
cd ../<slug> && jj workspace root      # must end in <slug>
cd ../<slug> && openspec list          # shows <slug> if it carries an OpenSpec change
```

If either fails, the workspace isn't ready — stop and report (likely needs `start-change`).

## The working contract (holds for the rest of the conversation)

| Concern | Rule |
|---|---|
| **cwd** | `openspec` / tests / dev run with `../<slug>` as cwd (`cd ../<slug> && …`); set it every call (the shell resets between tool calls). |
| **file ops** | All reads/edits via **native `Read`/`Edit`/`Write` on absolute paths under `../<slug>/`** (never a base path), and `Grep`/`Glob` to navigate. These always hit the workspace. |
| **Serena** | **Not used for workspace files** — reserved for normal base-checkout work. Its active project is the base checkout (`claude-code` excludes `activate_project`), so its *edit* tools would corrupt base and its *reads* of files you've edited go stale. |
| **bookmark** | `<type>/<slug>` — the future PR branch; `end-change` pushes it. |

## Why Serena is reserved for the base checkout (single-agent rule)

Serena holds one active project — the base checkout (`.serena/` lives there). Retargeting it would
need `activate_project`, but Serena's `claude-code` context **excludes that tool** (the project is
fixed from launch CWD; only `restart_language_server` is an includable optional tool). The standing
choice is to stay in a **single agent with retained context** — *not* to launch a second `claude`
inside the workspace — so Serena is simply never pointed at the workspace. Therefore, in a workspace:
do all file work with the native tools; use Serena only for base-checkout tasks, where it's correctly
targeted. (Settled — don't reach for `activate_project` or a second agent.)

## Hand-off

`change-context` stops after stating the contract. From there:
- open-ended work (debug / review / iterate) proceeds under the contract;
- `make-change` continues into implementing the OpenSpec change;
- `end-change` ships it.
