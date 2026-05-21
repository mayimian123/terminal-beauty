#!/usr/bin/env bash
# Backs up terminal config files into a timestamped directory.
# Usage: backup.sh [backup_root]   (default: ~/.terminal-beauty-backups)
# Prints the created backup directory path on stdout.
set -euo pipefail

backup_root="${1:-$HOME/.terminal-beauty-backups}"
stamp="$(date +%Y%m%d-%H%M%S)"
dest="$backup_root/$stamp"
i=1
while [ -e "$dest" ]; do
  dest="$backup_root/$stamp-$i"
  i=$((i + 1))
done
mkdir -p "$dest"
manifest="$dest/manifest.txt"
: > "$manifest"

backup_one() {
  local src="$1"
  [ -e "$src" ] || return 0
  local base
  base="$(printf '%s' "$src" | sed "s|^$HOME|HOME|; s|/|_|g")"
  cp -R "$src" "$dest/$base"
  printf '%s\t%s\n' "$base" "$src" >> "$manifest"
}

backup_one "$HOME/.zshrc"
backup_one "$HOME/.config/starship.toml"
backup_one "$HOME/.config/fish"

if defaults read com.googlecode.iterm2 >/dev/null 2>&1; then
  defaults export com.googlecode.iterm2 "$dest/iterm2.plist"
  printf '%s\t%s\n' "iterm2.plist" "defaults:com.googlecode.iterm2" >> "$manifest"
fi

if defaults read com.apple.Terminal >/dev/null 2>&1; then
  defaults export com.apple.Terminal "$dest/apple-terminal.plist"
  printf '%s\t%s\n' "apple-terminal.plist" "defaults:com.apple.Terminal" >> "$manifest"
fi

echo "$dest"
