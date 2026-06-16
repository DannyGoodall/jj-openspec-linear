# jj-openspec-linear

**jj-openspec-linear** is a Claude Code marketplace that ships a single plugin,
**`change-lifecycle`** — a tracked, human-paced code-change lifecycle built on
three things working together:

- **[Jujutsu (jj)](https://github.com/jj-vcs/jj) workspaces** — each change is
  isolated in its own workspace so concurrent changes never collide and the base
  checkout stays clean. All jj mechanics are delegated to the **`jj-vcs`** plugin;
  this plugin never reinvents jj.
- **[OpenSpec](https://github.com/openspec/openspec) proposals** — any change that
  would make a written specification stale is governed by an OpenSpec proposal
  authored, approved, and archived alongside the code.
- **An OPTIONAL issue tracker** — Linear (via its MCP server) when present, GitHub
  Issues (via the `gh` CLI) as a fallback, or no tracker at all. Issue tracking is
  a pluggable binding discovered at runtime, never a hard dependency.

The lifecycle takes a code change from triage through to a reviewable GitHub pull
request, one human-paced phase at a time:

```text
triage-change → start-change → make-change → end-change → (merge) → teardown-change
                                    ▲
                             change-context
                    (the "enter the workspace" primitive)
```

## Repo state

This repository is **implemented and spec-driven.** Every behaviour documented
here is pinned by a validated OpenSpec change under `openspec/changes/`, and the
corresponding manifests and skills are in place under
[`plugins/change-lifecycle/`](plugins/change-lifecycle/):

| Change | What it delivers | Status |
|--------|------------------|--------|
| `plugin-scaffold-and-distribution` | the marketplace manifest, the `change-lifecycle` plugin manifest, and the skill layout | ✓ applied |
| `tracked-change-lifecycle` | the six skills: `triage-change`, `start-change`, `make-change`, `end-change`, `teardown-change`, `change-context` | ✓ applied |
| `optional-issue-tracker-binding` | the runtime Linear/GitHub/none tracker binding and the bidirectional issue↔PR linkage | ✓ applied |
| `workflow-documentation` | this README and the [`docs/`](docs/) set | ✓ applied |

The changes remain in `openspec/changes/` (not yet archived) so the proposal →
spec → tasks history stays visible; run `openspec archive <change>` to fold each
delta into `openspec/specs/` when you want the specs to become the source of truth.

## Prerequisites and optional addons

### Hard prerequisite: the `jj-vcs` plugin

`change-lifecycle` delegates **all** jj mechanics to the `jj-vcs` plugin (the
`jj-vcs:jj` skill). It is a REQUIRED prerequisite. Marketplace manifests cannot
declare cross-plugin install dependencies, so each lifecycle skill **detects the
missing prerequisite at runtime** and stops with a clear, actionable message
rather than shelling out to raw jj.

```bash
# jj itself, colocated with git so GitHub/PRs still work
brew install jj                       # or your platform's package
cd your-repo && jj git init --colocate

# the jj reference/vocabulary layer the lifecycle delegates to
claude plugin marketplace add schpet/toolbox
claude plugin install jj-vcs@toolbox
```

### Optional addon: the Linear MCP server

Issue tracking is OPTIONAL. The plugin installs and runs with no Linear MCP
present. At runtime each issue-touching skill selects a tracker by fixed
precedence:

1. **Linear** — if the `mcp__linear-server__*` tools are present in the session.
2. **GitHub Issues** — else, if `gh` is installed and authenticated
   (`gh auth status` succeeds).
3. **No tracker** — else; the change is still fully tracked by its OpenSpec change
   folder, its jj bookmark, and its GitHub PR, and the skill says so plainly.

Linear is never a hard requirement. See
[docs/optional-components.md](docs/optional-components.md).

## Install

```bash
# 1. register this repo as a marketplace (GitHub, or a local clone path)
claude plugin marketplace add DannyGoodall/jj-openspec-linear   # or /path/to/jj-openspec-linear

# 2. refresh it — also how you pick up new plugin versions later
claude plugin marketplace update jj-openspec-linear

# 3. install the single plugin
claude plugin install change-lifecycle@jj-openspec-linear
```

Restart Claude Code after installing — newly installed skills only take effect in
sessions started after install.

## Quickstart

The lifecycle is driven by natural-language requests; the skill descriptions are
trigger-rich, so plain phrasings route to the right phase. A full run:

```text
# 1. TRIAGE — understand one issue: type, slug, OpenSpec gate, label. No fix, no workspace.
you:    triage PTS-100

# 2. START — create the issue (if needed), spin up the ../<slug> workspace + bookmark,
#    and author the OpenSpec proposal when the gate says yes. Setup only.
you:    start a change for PTS-100

# 3. MAKE — enter the workspace (via change-context), implement tasks.md, validate.
#    Does not push, does not open a PR.
you:    make the change

# 4. END — archive the OpenSpec change in-branch, push the bookmark, open the PR with
#    bidirectional issue links, move the issue to In Review. Stops — never self-merges.
you:    end the change / open the PR

#    ... a human reviews and merges the PR ...

# 5. TEARDOWN — after merge, remove the workspace, bookmark, and directory behind a
#    mandatory safety/confirmation gate. Removes only.
you:    tear down the workspace for PTS-100
```

Need to re-focus an existing session on a change someone else set up?

```text
you:    focus on the workspace for lane-stacking
```

`change-context` resolves and verifies the `../lane-stacking` workspace, loads its
proposal/tasks, and states the working contract for the rest of the session.

More concrete phrasings per skill are in
[docs/example-prompts.md](docs/example-prompts.md).

## The one-slug rule

A single kebab-case **slug** names three coordinated artifacts for the life of a
change, so the issue, workspace, branch, and PR stay aligned end to end:

| Artifact | Name |
|----------|------|
| jj workspace directory | `../<slug>` |
| jj bookmark | `<type>/<slug>` (`<type>` ∈ `fix` / `feat` / `chore`) |
| OpenSpec change-id | `<slug>` |

The slug is fixed at `start-change` and reused unchanged by every later phase.
See [docs/workflow.md](docs/workflow.md).

## Working in a workspace: `cw`

A bundled **pure-shell** helper (zsh + bash, no runtime) for the terminal side of a change:

```bash
cw <slug>             # cd to the ../<slug> workspace
cw <slug> --hydrate   # + copy .worktreeinclude matches (e.g. .env) from the primary —
                      #   jj only copies tracked files into a new workspace
cw <slug> --dev       # + free the configured port and run the project's declared dev command
```

Install once (survives plugin updates): `bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-cw.sh"`,
then add the printed `source` line to your shell rc. Details:
[references/cw-helper.md](plugins/change-lifecycle/references/cw-helper.md).

## Documentation

| Doc | Covers |
|-----|--------|
| [docs/features.md](docs/features.md) | each lifecycle skill — what it does, what it does NOT do, and how it hands off |
| [docs/workflow.md](docs/workflow.md) | the full triage → start → make → end → (merge) → teardown path, the OpenSpec gate, and slug coordination |
| [docs/optional-components.md](docs/optional-components.md) | behaviour WITH vs WITHOUT the Linear MCP, the GitHub Issues fallback, and the no-tracker guarantees |
| [docs/example-prompts.md](docs/example-prompts.md) | concrete phrasings that trigger each skill |
| [docs/issue-tracker.md](docs/issue-tracker.md) | how the plugin reads/writes Linear and GitHub issues, config discovery, the triage-label mapping, and bidirectional linkage |
| [docs/github-proposals.md](docs/github-proposals.md) | how an OpenSpec proposal travels into the PR and how the PR and issue record each other |
