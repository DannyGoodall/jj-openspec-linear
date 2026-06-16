## ADDED Requirements

### Requirement: Workspace entry by slug

The `cw` helper SHALL change the current shell's working directory to the sibling jj
workspace `../<slug>`, resolving the parent from `jj workspace root` so it works from any
workspace. Because a subprocess cannot change its parent shell's directory, the helper MUST
be a sourced shell function, not an executable script.

#### Scenario: Enter an existing workspace

- **WHEN** the user runs `cw <slug>` from inside any jj workspace and `../<slug>` exists
- **THEN** the shell's working directory becomes `../<slug>`

#### Scenario: Slug has no workspace

- **WHEN** the user runs `cw <slug>` and `../<slug>` is not a jj workspace
- **THEN** the helper prints a clear error naming the missing path and pointing at `start-change`, and does not change directory

#### Scenario: Not inside a jj workspace

- **WHEN** the user runs `cw <slug>` from a directory that is not within any jj workspace
- **THEN** the helper reports that it is not inside a jj workspace and exits non-zero

### Requirement: Hydrate gitignored files from the primary

The helper SHALL, when given `--hydrate`, copy every file and directory matching a
`.worktreeinclude` pattern from the primary checkout into the target workspace, overwriting
the destination so the primary remains the source of truth. Patterns that match nothing at the
source SHALL be skipped with a note rather than treated as an error.

#### Scenario: Copy declared gitignored paths

- **WHEN** `--hydrate` runs and `.worktreeinclude` lists `.env` and `.env.local` that exist in the primary
- **THEN** both files are copied into the workspace, overwriting any existing copies

#### Scenario: Non-matching pattern is skipped

- **WHEN** a `.worktreeinclude` pattern matches no file in the primary
- **THEN** the helper notes that pattern as skipped and continues with the remaining patterns

### Requirement: Dev dispatch runs a project-declared command

The helper SHALL, when given `--dev`, first hydrate, then free the configured port, then run
the project-declared dev command in the workspace. When no dev command is declared the helper
SHALL degrade to hydrating only and print a hint telling the user to run their own command. The
helper SHALL NOT hardcode any particular runtime or dev command.

#### Scenario: Configured dev command runs

- **WHEN** `cw <slug> --dev` runs and the config declares a dev command and a port
- **THEN** the helper hydrates, frees that port, and executes the declared command in the workspace

#### Scenario: No dev command declared

- **WHEN** `cw <slug> --dev` runs and no dev command is configured
- **THEN** the helper hydrates and prints a hint that no dev command is configured, without assuming a runtime

### Requirement: Runtime-free implementation

The helper SHALL be implemented in POSIX-compatible shell that works under both zsh and bash,
and MUST NOT require Bun, Node, or any other language runtime to perform entry, hydration, or
dev dispatch.

#### Scenario: Works without a JS runtime

- **WHEN** the helper runs in a repository where no Node or Bun runtime is installed
- **THEN** entry and hydration succeed using shell builtins and standard tools only

### Requirement: Workspace config format

The plugin SHALL define the workspace configuration in a `.worktreeinclude` file at the repo
root: newline-separated copy-pattern lines, with blank lines and `#` comments ignored, plus
optional directive lines that declare the dev command and the dev port. The parser MUST treat
copy patterns and directives unambiguously.

#### Scenario: Patterns and directives parsed

- **WHEN** `.worktreeinclude` contains copy patterns and a dev-command directive and a port directive
- **THEN** the helper hydrates using the copy patterns and uses the declared command and port for `--dev`

### Requirement: Stable-path delivery and install

The plugin SHALL deliver the helper as a bundled `cw.sh` that an install step copies or symlinks
to a stable location, which the user sources once from their shell rc. The helper MUST NOT be
sourced directly from the version-specific plugin cache path, so it survives plugin version
bumps.

#### Scenario: Install to a stable path

- **WHEN** the user runs the documented install step
- **THEN** `cw.sh` is placed at a stable path and a single `source` line referencing that path is what the user adds to their shell rc

#### Scenario: Survives a plugin update

- **WHEN** the plugin is updated to a new version and the install step is re-run
- **THEN** the stable path still resolves and the user's `source` line does not need to change

### Requirement: Scaffold the include file on start-change

When a change is started in a repo that has no `.worktreeinclude`, the plugin SHALL scaffold a
`.worktreeinclude` so hydration works the first time, and SHALL leave an existing
`.worktreeinclude` untouched.

#### Scenario: Scaffold when absent

- **WHEN** `start-change` runs in a repo with no `.worktreeinclude`
- **THEN** a starter `.worktreeinclude` is created listing common gitignored essentials

#### Scenario: Existing config preserved

- **WHEN** `start-change` runs in a repo that already has a `.worktreeinclude`
- **THEN** the existing file is left unchanged
