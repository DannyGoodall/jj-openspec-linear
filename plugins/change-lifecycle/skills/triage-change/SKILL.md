---
name: triage-change
description: >-
  Deep technical triage of a SINGLE issue: read the issue, the governing OpenSpec specs, and the code
  (via Serena symbol tools), then return a determination — what the fix actually requires, whether it
  impacts OpenSpec or is a code-only change that leaves specs and code in sync, plus a proposed
  type/slug and fix-sketch. Applies a canonical triage label (ready-for-agent / ready-for-human /
  needs-info) via the active issue-tracking binding as its final step. Understands; does NOT fix and
  does NOT create a workspace. Use to "triage this change/bug", "scope <ID>", "what would it take to
  fix X", "does this touch the spec / need OpenSpec", or "is this ready for an agent". Complements
  (does not replace) the board-level `triage` skill, and feeds `start-change`.
---

# Triage Change

The investigation layer in front of `start-change`. Given one issue, work out **what the change really
is** and **whether it moves an OpenSpec requirement**, then label it so a human or an AFK agent can pick
it up. It produces a determination and a label — nothing else: no fix, no jj workspace, no proposal.
`start-change` consumes the determination and does that.

Relationship to the generic `triage` skill: that one runs the board-level role/state machine across many
issues. `triage-change` is the single-issue *technical* deep-dive that produces the OpenSpec-impact call
and fix-sketch. They share the same label vocabulary (`${CLAUDE_PLUGIN_ROOT}/references/triage-labels.md`);
this skill reuses those mechanics rather than inventing its own.

Issue tracking is **optional and pluggable**. Resolve the binding (Linear / GitHub / none) per
`${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` and read/label the issue through it — not through
Linear specifically. In **no-tracker mode** there is no issue to label: return the determination
in-thread and say plainly that no issue was labelled.

## The determination (what this skill returns)

```
{ issue, type, slug, openspec: yes|no, impacted-specs[], fix-sketch, confidence, label }
```

- **type** — `fix` | `feat` | `chore` (conventional-commit style; mirrors a `Bug`/`Feature` category).
- **slug** — kebab change name `start-change` reuses for workspace/bookmark/(change-id). Don't repeat the type.
- **openspec** — the gate result (below). **impacted-specs[]** — the spec dirs that would change, empty if `no`.
- **fix-sketch** — the concrete approach (files/symbols, shape of the change), enough for an implementer to start.
- **label** — `ready-for-agent` | `ready-for-human` | `needs-info` (decision rule below).

## Workflow

### 1 — Resolve the binding & read the issue
Select the issue-tracking mode (`references/issue-tracking.md`). Read the issue and its comments via the
binding (Linear `get_issue` + `list_comments`; GitHub `gh issue view --comments`; no-tracker: take the
request from the user in-thread). Extract symptom, repro, any cited files/symbols, acceptance criteria.
If it's underspecified to the point you can't determine the fix → label `needs-info` and stop (step 4 short-circuit).

### 2 — Read the governing specs
Find the OpenSpec specs that *own* the behaviour (`openspec/specs/<cap>/spec.md`). Grep is the right tool
here — specs are prose. Note the exact requirement(s) the change would touch.

### 3 — Read the code — via Serena
Use **Serena symbol tools** (`find_symbol` with `include_body`, `get_symbols_overview`,
`find_referencing_symbols`) to read the relevant functions by name — **not** whole-file `Read`/`grep`.
It is far more token-efficient. Confirm the actual current behaviour against the issue's claims and the specs.

### 4 — Run the OpenSpec gate
**Ask one question:** *after this change is made, would the OpenSpec design or specs have to change to
reflect the new reality?*
- **No → `openspec: no`.** Every requirement and `design.md` stays accurate — a true bug fix restoring
  intended behaviour, a typo, a CSS hue, an off-by-one. Code and spec remain in sync.
- **Yes → `openspec: yes`.** It adds/alters/removes a requirement, changes a data model / migration /
  API / auth, or introduces a capability — anything making the specs stale. **When unsure, yes.**
  Watch the subtle case: a `Bug` whose *correct fix contradicts a written requirement* is still
  `openspec: yes`, because resolving it changes the written contract — list that requirement among the impacted specs.

**Short-circuit:** if the issue lacks the information to determine the fix, stop here. Record what's
missing and label `needs-info` — do **not** guess a type, slug, or gate result.

### 5 — Decide the label
- **`ready-for-agent`** — fix-sketch concrete, OpenSpec call clear, no unresolved design choice. An AFK
  agent could run `start-change` and implement it.
- **`ready-for-human`** — a genuine design decision, product judgement, or risky trade-off remains.
- **`needs-info`** — can't determine the fix without more from the reporter.

### 6 — Record and label
Apply the label and post the determination per `references/determination-and-labels.md` (preserve the
categorical `Bug`/`Feature` label; `ready-for-*` also moves status to `Todo`). Post the determination as
an issue comment **opening with the disclaimer** `> *This was generated by AI during triage.*` (the
triage convention). In **no-tracker mode** there's no issue: print the determination in-thread and state
that no issue was labelled. Then report the determination in-thread and **stop** — hand off to
`start-change` (or a human).

## Principles

- **Understand, don't fix.** No code, no workspace, no proposal. The output is a determination + a label.
- **Gate honestly via the specs.** The OpenSpec call requires actually reading the spec — a `Bug` category
  is not evidence of `openspec: no`.
- **Serena for code.** Symbol-level reads, not whole-file scans.
- **Reuse, don't reinvent.** Labels/mechanics → `references/triage-labels.md` + the `triage` skill;
  the determination → `start-change`.
- **Idempotent.** Re-triaging updates the same determination comment and label in place — never a duplicate.

## Bundled resources

- `${CLAUDE_PLUGIN_ROOT}/references/issue-tracking.md` — binding selection (Linear → GitHub → none), ops, bidirectional linkage, runtime discovery.
- `${CLAUDE_PLUGIN_ROOT}/references/triage-labels.md` — canonical role → tracker-mechanism map.
- `references/determination-and-labels.md` — the determination record format, the label decision rule, and the mechanics of applying the label (preserve the categorical label, set `Todo`).
