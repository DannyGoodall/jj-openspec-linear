# plugin-packaging Specification

## Purpose
TBD - created by archiving change plugin-scaffold-and-distribution. Update Purpose after archive.
## Requirements
### Requirement: Marketplace manifest

The repository SHALL contain a `.claude-plugin/marketplace.json` at its root that
declares a marketplace named `jj-openspec-linear`, sets the plugin root to
`./plugins` (via `metadata.pluginRoot`), and lists exactly one plugin,
`change-lifecycle`, sourced at `./plugins/change-lifecycle`.

#### Scenario: Marketplace declares the single plugin

- **WHEN** a user adds this repository as a Claude Code marketplace
- **THEN** `.claude-plugin/marketplace.json` resolves with `name`
  `jj-openspec-linear`, `metadata.pluginRoot` `./plugins`, and a single `plugins`
  entry whose `name` is `change-lifecycle` and whose `source` is
  `./plugins/change-lifecycle`

#### Scenario: Plugin source path exists under the plugin root

- **WHEN** the marketplace manifest is resolved
- **THEN** the declared source `./plugins/change-lifecycle` MUST exist relative to
  the repository root so the plugin can be installed from this marketplace

### Requirement: Plugin manifest

The plugin SHALL provide a manifest at
`plugins/change-lifecycle/.claude-plugin/plugin.json` declaring its `name`
(`change-lifecycle`), a `version` that is a valid semantic version, and a
trigger-rich `description` that names the lifecycle skills so Claude Code can
surface the plugin for relevant requests.

#### Scenario: Manifest exposes name, semver version, and description

- **WHEN** Claude Code loads the `change-lifecycle` plugin
- **THEN** `plugins/change-lifecycle/.claude-plugin/plugin.json` provides `name`
  `change-lifecycle`, a `version` matching `MAJOR.MINOR.PATCH`, and a non-empty
  `description`

#### Scenario: Description is trigger-rich

- **WHEN** a user describes a tracked code change in conversation
- **THEN** the manifest `description` references the lifecycle vocabulary
  (e.g. triage / start / make / end / teardown a change) so the plugin is a
  plausible match for the request

### Requirement: Skill directory layout

Every lifecycle skill SHALL live at
`plugins/change-lifecycle/skills/<skill-name>/SKILL.md`, where `<skill-name>` is
the canonical kebab-case skill name, and MAY include an optional `references/`
subdirectory for supporting material. No skill SHALL be defined outside this
layout.

#### Scenario: Each skill resolves at the canonical path

- **WHEN** the plugin is installed and a lifecycle skill is invoked
- **THEN** that skill is found at
  `plugins/change-lifecycle/skills/<skill-name>/SKILL.md` for each canonical name
  (`triage-change`, `start-change`, `make-change`, `end-change`,
  `teardown-change`, `change-context`)

#### Scenario: Supporting material lives under references

- **WHEN** a skill needs supporting files beyond its `SKILL.md`
- **THEN** those files MUST live in that skill's optional `references/`
  subdirectory rather than elsewhere in the plugin tree

### Requirement: Required prerequisite jj-vcs

The plugin SHALL document `jj-vcs` as a REQUIRED prerequisite that provides the
`jj-vcs:jj` capability. Lifecycle skills SHALL delegate all jj mechanics to it
and SHALL detect a missing `jj-vcs:jj` capability and stop with a clear,
actionable message rather than reinventing jj.

#### Scenario: Missing prerequisite stops with a clear message

- **WHEN** a lifecycle skill runs and the `jj-vcs:jj` capability is not available
- **THEN** the skill stops and reports that the `jj-vcs` plugin is a required
  prerequisite, instead of attempting raw jj operations itself

#### Scenario: Prerequisite documented in packaging

- **WHEN** a user reads the plugin's distribution metadata or documentation
- **THEN** `jj-vcs` is stated as a REQUIRED prerequisite the user must install
  separately

### Requirement: Optional Linear MCP addon

Packaging SHALL declare the Linear MCP server (`mcp__linear-server__*`) as an
OPTIONAL addon. The plugin SHALL be fully installable and usable when the Linear
MCP server is absent; no marketplace or plugin manifest entry SHALL make Linear a
hard install-time dependency.

#### Scenario: Plugin installs and runs without Linear MCP

- **WHEN** a user installs the plugin in an environment with no Linear MCP server
  configured
- **THEN** installation succeeds and the lifecycle is usable, with issue tracking
  treated as an optional, separately-specified capability

#### Scenario: Linear declared optional, not required

- **WHEN** packaging metadata is inspected
- **THEN** the Linear MCP server is declared OPTIONAL and is never listed as a
  required prerequisite alongside `jj-vcs`

### Requirement: OpenSpec project completeness

The repository SHALL keep `openspec/config.yaml` populated with project context
so that OpenSpec-generated artifacts inherit consistent project framing.

#### Scenario: Config provides project context to generated artifacts

- **WHEN** an OpenSpec command generates or validates an artifact in this repo
- **THEN** `openspec/config.yaml` exists and carries the project context
  describing the marketplace, the single plugin, the lifecycle skills, and the
  required/optional dependency split

