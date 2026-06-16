# Teardown safety assessment + recovery

The facts `teardown-change` gathers before the gate, the exact removal sequence, and how to undo it. All
jj mechanics belong to the `jj-vcs:jj` skill.

## Assessment commands (run before the gate)

```bash
# Merged? (safe to tear down)
gh pr view <type>/<slug> --json state,mergedAt        # state == MERGED → safe
# …or, without gh: is the bookmark commit already on main?
jj log -r '<type>/<slug> & ::main@origin' --no-graph  # non-empty → merged/landed
# Colocated-jj gotcha: gh commands that infer the "current branch" (e.g. gh pr merge)
# may print "could not determine current branch: not on any branch" because jj leaves
# git in a detached state. The merge still happens server-side — judge merge state by
# `gh pr view ... --json state,mergedAt`, NOT by the command's exit code.

# Pushed & current? (unpushed commits = unsafe)
jj log -r '<type>/<slug>' --no-graph                  # compare against the remote-tracking bookmark

# Working-tree state (the irrecoverable part lives here)
cd ../<slug> && jj st                                  # uncommitted changes (auto-snapshotted into @)
cd ../<slug> && jj file list --no-pager 2>/dev/null   # tracked files
# Untracked files beyond the standard hydrated ones are the real loss:
cd ../<slug> && git status --porcelain --ignored | grep '^!!\|^??'   # ignored + untracked
```

The only **irrecoverable** loss is untracked content in the directory — `.env.local` and dependency dirs
(e.g. `node_modules`) are regenerable (re-hydrate + reinstall), but any ad-hoc untracked file is gone.
Flag those by name in the gate.

## Removal sequence (only after an affirmative gate choice)

Run from the **primary** checkout (you can't forget the workspace you're standing in; the jj guard also
blocks workspace ops inside a worker workspace):

```bash
cd <primary>                               # the repo root
jj workspace forget <slug>                 # detach the workspace from the repo
rm -rf ../<slug>                           # remove the working directory
jj bookmark delete <type>/<slug>           # local bookmark; the remote branch is usually deleted on PR merge
jj bookmark forget <type>/<slug>           # drop the now-stale @origin tracking ref (a --delete-branch
                                           #   merge removes the remote branch, but jj keeps the tracking
                                           #   ref until a fetch); `jj git fetch` also prunes it
jj workspace list                          # verify <slug> is gone
```

Order matters: `forget` before `rm` so jj isn't left pointing at a missing working copy. Deleting the
bookmark is optional if it's already gone from the remote, but tidy.

## Recovering a torn-down change

`jj` never discards commits on `forget`/`rm` — only the working directory and tracking go away:

```bash
jj op log                                                  # find the operation just before teardown
jj op restore <op-id>                                      # roll the repo state back, or…
jj new <change-id>                                         # …re-check-out the change's commit by its id
jj workspace add --name <slug> -r <change-id> ../<slug>    # recreate the workspace if needed
```

So: **committed work is recoverable; the directory's untracked files are not.** That asymmetry is what
the gate must communicate.
