# cw.sh — hop between jj workspaces by change slug, optionally hydrate + boot dev.
#
# Pure shell (zsh + bash); no language runtime (Bun/Node/…) required. `cd` must live in a
# sourced shell function because a subprocess cannot change its parent shell's directory.
#
# Install (one time): copy this file to a stable path and source it from your shell rc — do
# NOT source it from the plugin cache (that path is version-specific). The bundled installer
# does this for you:
#   bash "<plugin>/scripts/install-cw.sh"        # copies to ~/.local/share/change-lifecycle/cw.sh
# then add the line it prints to ~/.zshrc or ~/.bashrc:
#   source "$HOME/.local/share/change-lifecycle/cw.sh"
# Re-run the installer after a plugin update; the source line never changes.
#
# Usage:
#   cw <slug>                    # cd to the sibling workspace ../<slug>
#   cw <slug> --hydrate          # also copy .worktreeinclude matches from the primary
#   cw <slug> --dev [--port N]   # hydrate, free the port, run the declared dev command
#
# Config — .worktreeinclude at the repo root:
#   .env                 # copy-pattern lines (globs allowed); blank lines and # comments ignored
#   .env.local
#   config/*.local.json
#   dev: bun run dev     # optional: the command `--dev` runs (any shell, any stack)
#   port: 5173           # optional: the port `--dev` frees before running

# --- internal helpers (prefixed _cw_) --------------------------------------------------

# Nearest ancestor of the cwd that contains a .jj entry (a jj workspace root).
_cw_workspace_root() {
	local dir
	dir=$(pwd -P)
	while [ -n "$dir" ]; do
		[ -e "$dir/.jj" ] && { printf '%s\n' "$dir"; return 0; }
		[ "$dir" = "/" ] && break
		dir=$(dirname "$dir")
	done
	return 1
}

# Resolve the PRIMARY checkout root from any workspace root.
# Primary: .jj/repo is a directory (the store). Added workspace: .jj/repo is a FILE holding a
# relative path to <primary>/.jj/repo, so <primary> = (dir of that pointer)/.. resolved.
_cw_primary_root() {
	local any="$1" entry="$1/.jj/repo" pointer
	[ -d "$entry" ] && { printf '%s\n' "$any"; return 0; }
	if [ -f "$entry" ]; then
		pointer=$(cat "$entry")
		( cd "$any/.jj/$(dirname "$pointer")/.." 2>/dev/null && pwd -P ) && return 0
	fi
	return 1
}

# Print the trimmed value of a `key: value` directive from .worktreeinclude, or nothing.
_cw_config_value() {
	local inc="$1/.worktreeinclude" key="$2" line
	[ -f "$inc" ] || return 0
	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			"$key":*)
				line=${line#*:}
				printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
				return 0 ;;
		esac
	done < "$inc"
}

# Copy every .worktreeinclude pattern match from the primary into the target workspace.
_cw_hydrate() {
	local primary="$1" target="$2" inc="$1/.worktreeinclude"
	if [ ! -f "$inc" ]; then
		echo "cw: no .worktreeinclude at $primary — nothing to hydrate (start-change scaffolds one)" >&2
		return 0
	fi
	# nullglob so non-matching patterns expand to nothing, in both shells.
	local _bash_nullglob=""
	if [ -n "$ZSH_VERSION" ]; then
		setopt local_options null_glob 2>/dev/null
	elif [ -n "$BASH_VERSION" ]; then
		_bash_nullglob=$(shopt -p nullglob)
		shopt -s nullglob
	fi
	echo "cw: hydrate $primary -> $target"
	local copied=0 line pattern m rel
	while IFS= read -r line || [ -n "$line" ]; do
		pattern=$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
		[ -z "$pattern" ] && continue
		case "$pattern" in
			\#*) continue ;;            # comment
			dev:*|port:*) continue ;;   # directive, not a copy pattern
		esac
		local matched=0
		for m in "$primary"/$pattern; do
			[ -e "$m" ] || continue
			rel=${m#"$primary"/}
			mkdir -p "$target/$(dirname "$rel")"
			cp -R "$m" "$target/$rel"
			echo "  ✓ $rel"
			matched=1; copied=$((copied + 1))
		done
		[ "$matched" -eq 0 ] && echo "  · $pattern — no match at source, skipped"
	done < "$inc"
	[ -n "$_bash_nullglob" ] && eval "$_bash_nullglob"
	if [ "$copied" -gt 0 ]; then echo "cw: hydrated $copied path(s)."; else echo "cw: nothing to hydrate."; fi
}

# Hydrate, free the configured port, then run the declared dev command (degrade if none).
_cw_dev() {
	local primary="$1" target="$2" port="$3" cmd
	_cw_hydrate "$primary" "$target"
	cmd=$(_cw_config_value "$primary" dev)
	[ -z "$port" ] && port=$(_cw_config_value "$primary" port)
	if [ -n "$port" ]; then
		if command -v lsof >/dev/null 2>&1; then
			local pids pid
			pids=$(lsof -ti tcp:"$port" 2>/dev/null)
			for pid in $pids; do
				kill "$pid" 2>/dev/null && echo "cw: freed port $port (killed pid $pid)"
			done
		else
			echo "cw: lsof not available — skipping port $port free" >&2
		fi
	fi
	if [ -z "$cmd" ]; then
		echo "cw: no dev command configured. Add 'dev: <command>' to .worktreeinclude, or run your own here. Hydrated only." >&2
		return 0
	fi
	echo "cw: dev in $target -> $cmd"
	( cd "$target" && eval "$cmd" )
}

# --- the sourced entry point -----------------------------------------------------------

cw() {
	[ -n "$ZSH_VERSION" ] && emulate -L zsh
	local slug="$1"
	if [ -z "$slug" ]; then
		echo "usage: cw <slug> [--hydrate] [--dev] [--port N]" >&2
		return 1
	fi
	shift

	local root parent target
	root=$(_cw_workspace_root) || { echo "cw: not inside a jj workspace" >&2; return 1; }
	parent=$(dirname "$root")
	target="$parent/$slug"
	if [ ! -e "$target/.jj" ]; then
		echo "cw: no jj workspace at $target (create it with start-change / 'jj workspace add')" >&2
		return 1
	fi

	local do_hydrate=0 do_dev=0 port=""
	while [ $# -gt 0 ]; do
		case "$1" in
			--hydrate) do_hydrate=1 ;;
			--dev) do_dev=1 ;;
			--port) port="$2"; shift ;;
			*) echo "cw: unknown option $1" >&2; return 1 ;;
		esac
		shift
	done

	cd "$target" || return 1
	local primary
	primary=$(_cw_primary_root "$root") || primary="$root"
	if [ "$do_dev" -eq 1 ]; then
		_cw_dev "$primary" "$target" "$port"
	elif [ "$do_hydrate" -eq 1 ]; then
		_cw_hydrate "$primary" "$target"
	fi
}
