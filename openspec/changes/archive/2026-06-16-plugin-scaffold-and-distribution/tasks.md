# Tasks: plugin-scaffold-and-distribution

## 1. Marketplace manifest

- [x] 1.1 Create `.claude-plugin/marketplace.json` at the repo root.
- [x] 1.2 Set `name` to `jj-openspec-linear` and add `owner` (`{ name }`) mirroring claude-code-jj.
- [x] 1.3 Add `metadata` with `description`, `homepage`, and `pluginRoot` `./plugins`.
- [x] 1.4 Add a single `plugins[]` entry: `name` `change-lifecycle`, `source` `./plugins/change-lifecycle`, plus a description.

## 2. Plugin manifest

- [x] 2.1 Create `plugins/change-lifecycle/.claude-plugin/plugin.json`.
- [x] 2.2 Set `name` to `change-lifecycle` and a valid semver `version` (e.g. `0.1.0`).
- [x] 2.3 Write a trigger-rich `description` naming the lifecycle vocabulary (triage / start / make / end / teardown a change).

## 3. Skill directory skeleton

- [x] 3.1 Create `plugins/change-lifecycle/skills/`.
- [x] 3.2 Create a `<skill-name>/` subdir for each canonical skill: `triage-change`, `start-change`, `make-change`, `end-change`, `teardown-change`, `change-context`.
- [x] 3.3 Real `SKILL.md` content for each skill is delivered by the tracked-change-lifecycle change (no placeholder needed).
- [x] 3.4 Document that an optional `references/` subdir is permitted per skill.

## 4. Prerequisites and optional addon

- [x] 4.1 Document `jj-vcs` as a REQUIRED prerequisite in the plugin's distribution metadata/docs.
- [x] 4.2 Record the runtime detection contract: skills probe for the `jj-vcs:jj` capability and stop with a clear message when absent (probe code lands with skill content).
- [x] 4.3 Declare the Linear MCP server as an OPTIONAL addon; ensure no manifest entry makes it a hard install-time dependency.

## 5. OpenSpec project completeness

- [x] 5.1 Verify `openspec/config.yaml` is populated with project context (already done) so generated artifacts inherit it.
- [x] 5.2 Run `openspec validate plugin-scaffold-and-distribution --strict` and confirm it passes.
