# Design: plugin-scaffold-and-distribution

## Context

The lifecycle (triage-change → start-change → make-change → end-change →
teardown-change, plus change-context) is currently only described in
`openspec/config.yaml`; nothing is installable. Before any skill behaviour is
written, the repo needs the packaging skeleton: a marketplace manifest, a plugin
manifest, and the skill directory layout Claude Code expects.

A sibling repo, `claude-code-jj`, already ships a working marketplace + plugins
and is the schema reference for this work. Its
`.claude-plugin/marketplace.json` uses `name`, `owner`, and `metadata`
(with `description`, `homepage`, `pluginRoot`) plus a `plugins[]` array of
`{ name, source, description }`; its plugin manifests
(e.g. `plugins/jj-lifecycle/.claude-plugin/plugin.json`) use
`{ name, version, description }`. We mirror those exact shapes so the two repos
stay consistent and Claude Code's loader treats them identically.

This change packages only. Skill content (the SKILL.md bodies and their
`references/`) is owned by the separate tracked-change-lifecycle change, and the
GitHub Issues fallback for the optional Linear binding is its own change too.

## Goals / Non-Goals

Goals:
- Make this repo an installable Claude Code marketplace exposing exactly one
  plugin, `change-lifecycle`.
- Mirror the manifest schema used by `claude-code-jj`.
- Establish the canonical skill directory layout so later skill content drops in
  without restructuring.
- Declare `jj-vcs` REQUIRED and Linear MCP OPTIONAL at the packaging level, and
  define how skills detect the missing prerequisite at runtime.

Non-Goals:
- Authoring any SKILL.md behaviour (tracked-change-lifecycle change).
- Implementing the GitHub Issues fallback for issue tracking (separate change).
- Adding hooks, agents, or MCP server bundling — none are needed for packaging.

## Decisions

### Own marketplace vs folding into claude-code-jj

We ship a **dedicated** marketplace, `jj-openspec-linear`, rather than adding the
plugin to `claude-code-jj`. The two have different audiences and dependency
shapes: `claude-code-jj` is about concurrent multi-agent orchestration on jj
workspaces, whereas this is a solo, human-paced, OpenSpec-governed, optionally
Linear-tracked lifecycle. A separate marketplace keeps install surfaces,
versioning, and the prerequisite story independent. (`jj-vcs` is shared as a
prerequisite either way.)

### Single plugin vs multiple plugins

One plugin, `change-lifecycle`, holds all six lifecycle skills. They form a
single coordinated workflow that shares the one-slug-names-everything convention
(workspace dir, bookmark, OpenSpec change-id); splitting them across plugins
would force users to install several pieces to get one coherent lifecycle and
would fragment versioning. The optional Linear binding does not justify a second
plugin — optionality is handled by runtime capability detection, not by a
separate install unit.

### Runtime prerequisite detection

`jj-vcs` is a hard prerequisite but Claude Code marketplace manifests do not
express cross-plugin install dependencies, so detection happens at **runtime**.
Each lifecycle skill, before performing any jj work, probes for the `jj-vcs:jj`
capability (and/or the `jj` binary on PATH). If it is absent, the skill stops
immediately with a clear message telling the user to install the `jj-vcs` plugin,
rather than shelling out to raw jj itself. This keeps the "never reinvent jj"
delegation boundary enforceable from the very first installed skill, and is
specified here (the requirement) even though the per-skill probe code lands with
the skill content.

### Mirror the claude-code-jj manifest schema

- `marketplace.json`: `name` (`jj-openspec-linear`), `owner` (`{ name }`),
  `metadata` (`{ description, homepage, pluginRoot: "./plugins" }`), and
  `plugins` (a one-element array `{ name: "change-lifecycle", source:
  "./plugins/change-lifecycle", description }`).
- `plugin.json`: `{ name, version, description }` with `version` a valid semver
  and a trigger-rich `description`.

Mirroring the exact keys (not inventing new ones) means the loader behaviour is
already proven by the sibling repo.

## Risks / Trade-offs

- **No install-time dependency enforcement for jj-vcs.** Marketplace manifests
  can't declare it, so a user can install `change-lifecycle` without `jj-vcs`.
  Mitigation: runtime detection + clear stop message (specified above); we accept
  the late failure because there is no manifest mechanism for it.
- **Schema drift from claude-code-jj.** If the sibling repo's schema evolves, the
  two could diverge. Mitigation: we copied the current shape verbatim and call out
  the mirror relationship here so future changes can re-sync.
- **Empty skill skeleton merged before content.** The skills/ tree exists before
  the SKILL.md bodies. Mitigation: the layout requirement is enforced by spec, and
  tracked-change-lifecycle fills the bodies; the skeleton is harmless on its own.
