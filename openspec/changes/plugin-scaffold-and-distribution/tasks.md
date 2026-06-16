# Tasks: plugin-scaffold-and-distribution

## 1. Marketplace manifest

- [ ] 1.1 Create `.claude-plugin/marketplace.json` at the repo root.
- [ ] 1.2 Set `name` to `jj-openspec-linear` and add `owner` (`{ name }`) mirroring claude-code-jj.
- [ ] 1.3 Add `metadata` with `description`, `homepage`, and `pluginRoot` `./plugins`.
- [ ] 1.4 Add a single `plugins[]` entry: `name` `change-lifecycle`, `source` `./plugins/change-lifecycle`, plus a description.

## 2. Plugin manifest

- [ ] 2.1 Create `plugins/change-lifecycle/.claude-plugin/plugin.json`.
- [ ] 2.2 Set `name` to `change-lifecycle` and a valid semver `version` (e.g. `0.1.0`).
- [ ] 2.3 Write a trigger-rich `description` naming the lifecycle vocabulary (triage / start / make / end / teardown a change).

## 3. Skill directory skeleton

- [ ] 3.1 Create `plugins/change-lifecycle/skills/`.
- [ ] 3.2 Create a `<skill-name>/` subdir for each canonical skill: `triage-change`, `start-change`, `make-change`, `end-change`, `teardown-change`, `change-context`.
- [ ] 3.3 Place a placeholder `SKILL.md` in each subdir (actual skill content is delivered by the tracked-change-lifecycle change).
- [ ] 3.4 Document that an optional `references/` subdir is permitted per skill.

## 4. Prerequisites and optional addon

- [ ] 4.1 Document `jj-vcs` as a REQUIRED prerequisite in the plugin's distribution metadata/docs.
- [ ] 4.2 Record the runtime detection contract: skills probe for the `jj-vcs:jj` capability and stop with a clear message when absent (probe code lands with skill content).
- [ ] 4.3 Declare the Linear MCP server as an OPTIONAL addon; ensure no manifest entry makes it a hard install-time dependency.

## 5. OpenSpec project completeness

- [ ] 5.1 Verify `openspec/config.yaml` is populated with project context (already done) so generated artifacts inherit it.
- [ ] 5.2 Run `openspec validate plugin-scaffold-and-distribution --strict` and confirm it passes.
