# Example prompts

The lifecycle skills have trigger-rich descriptions, so you drive them with plain
natural-language requests — no slash commands required. Below are concrete
phrasings that route to each skill. An issue reference (e.g. `PTS-100`) or a change
slug (e.g. `lane-stacking`) can usually be dropped straight into the request.

See [features.md](features.md) for what each skill does and
[workflow.md](workflow.md) for how they connect.

## `triage-change`

> Understand one issue and produce a determination. No fix, no workspace.

- "triage PTS-100"
- "scope PTS-100 — what would it take to fix it?"
- "does this bug touch the spec, or is it code-only?"
- "is PTS-100 ready for an agent?"
- "triage this issue and label it"

## `start-change`

> Set up the issue, workspace, bookmark, and (if the gate says yes) the proposal.

- "start a change for PTS-100"
- "spin up a workspace for adding a rate limiter"
- "kick off a feature for lane stacking"
- "open a spec/proposal for this change and set up its workspace"
- "set up the work for PTS-100 but don't implement it yet"

## `make-change`

> Enter the verified workspace and implement `tasks.md`.

- "make the change"
- "implement PTS-100"
- "do the lane-stacking change"
- "work through the tasks for this change"
- "continue implementing the change in its workspace"

## `change-context`

> Re-focus this session on an existing change's workspace. Sets context only.

- "focus on the workspace for lane-stacking"
- "work in the jj workspace called lane-stacking"
- "switch context to PTS-100's workspace"
- "load the change for PTS-100 so we can keep working on it"

## `end-change`

> Archive, push the bookmark, open the PR with bidirectional links. Stops — no merge.

- "end the change"
- "open the PR for this workspace"
- "ship / finish this change"
- "wrap up PTS-100 and open the pull request"

## `teardown-change`

> After the PR has merged: guarded, destructive cleanup of the workspace.

- "tear down the workspace for PTS-100"
- "clean up the lane-stacking workspace"
- "remove the workspace for this merged change"
- "prune the finished change for PTS-100"

---

These triggers are intentionally broad. If a phrasing is ambiguous, the skill
states which phase it thinks you mean before acting — and issue-touching skills
announce their tracker mode (Linear / GitHub / none) so you always know where the
record lives. See [optional-components.md](optional-components.md).
