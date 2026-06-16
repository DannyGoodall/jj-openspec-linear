#!/usr/bin/env bash
# install-cw.sh — copy the bundled cw.sh to a stable path you can source from your shell rc.
#
# The plugin cache path is version-specific (…/cache/<marketplace>/<plugin>/<version>/…), so
# sourcing cw.sh from there would break on every update. This copies it to a stable location
# and prints the single `source` line to add to your rc. Re-run after a plugin update — the
# stable path and the source line never change.
#
#   bash "<plugin>/scripts/install-cw.sh"            # default dest: ~/.local/share/change-lifecycle
#   CW_DEST_DIR=~/somewhere bash install-cw.sh       # override destination
set -eu

src_dir=$(cd "$(dirname "$0")" && pwd -P)
src="$src_dir/cw.sh"
[ -f "$src" ] || { echo "install-cw: cannot find cw.sh next to this script ($src)" >&2; exit 1; }

dest_dir="${CW_DEST_DIR:-$HOME/.local/share/change-lifecycle}"
dest="$dest_dir/cw.sh"

mkdir -p "$dest_dir"
cp "$src" "$dest"
echo "install-cw: installed cw.sh -> $dest"
echo
echo "Add this line to your shell rc (~/.zshrc or ~/.bashrc), then restart your shell:"
echo
echo "    source \"$dest\""
echo
echo "Then: cw <slug> [--hydrate] [--dev]"
