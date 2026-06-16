# Change: plugin-scaffold-and-distribution

## Why

Today this repo is just a directory of intentions: it describes a tracked,
human-paced code-change lifecycle (triage-change → start-change → make-change →
end-change → teardown-change, plus change-context) but ships nothing a user can
install. For anyone to actually run the lifecycle, the repo has to become a real
Claude Code marketplace exposing a single installable plugin, with its skills
laid out where Claude Code expects to find them.

Packaging also has to make two dependency facts explicit and machine-checkable up
front, before any skill behaviour is authored:

- the lifecycle delegates **all** jj mechanics to the `jj-vcs` plugin, so `jj-vcs`
  is a HARD prerequisite — the plugin must never reinvent jj; and
- issue tracking via the Linear MCP server is OPTIONAL — the plugin must install
  and run with no Linear MCP present (the GitHub Issues fallback itself is
  specified by a separate change; here we only declare the optionality).

This change covers ONLY packaging and distribution. The skill behaviours
themselves are delivered by the separate tracked-change-lifecycle change.

## What Changes

- Add `.claude-plugin/marketplace.json` declaring the marketplace
  `jj-openspec-linear` with `pluginRoot` `./plugins` and a single plugin entry,
  `change-lifecycle`, sourced at `./plugins/change-lifecycle`.
- Add `plugins/change-lifecycle/.claude-plugin/plugin.json` declaring the plugin
  name, a semver version, and a trigger-rich description.
- Establish the skill directory layout: every lifecycle skill lives at
  `plugins/change-lifecycle/skills/<skill-name>/SKILL.md` (with an optional
  `references/` subdir). This change creates the skeleton only; skill content is
  owned by the tracked-change-lifecycle change.
- Document `jj-vcs` as a REQUIRED prerequisite and define the runtime
  capability-detection contract: skills probe for the `jj-vcs:jj` capability and
  stop with a clear message when it is absent rather than reinventing jj.
- Declare the Linear MCP server as an OPTIONAL addon at the packaging level; the
  plugin is fully installable and usable without it.
- Keep the OpenSpec project context complete (`openspec/config.yaml` is already
  populated) so generated artifacts inherit it.

## Capabilities

### New Capabilities

- `plugin-packaging`: how this repo is distributed as a Claude Code
  marketplace + single plugin (`change-lifecycle`), where its skills live, and
  which dependencies are required (`jj-vcs`) versus optional (Linear MCP).

### Modified Capabilities

_None._

## Impact

- New files: `.claude-plugin/marketplace.json`,
  `plugins/change-lifecycle/.claude-plugin/plugin.json`, and the
  `plugins/change-lifecycle/skills/` skeleton.
- New spec capability: `plugin-packaging`.
- No skill behaviour changes here — those land via tracked-change-lifecycle.
- Once merged, the repo is installable as a marketplace; the only runtime
  prerequisite a user must already have is the `jj-vcs` plugin.
