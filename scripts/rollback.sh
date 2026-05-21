#!/usr/bin/env bash
# Restores terminal config files from a backup directory.
# Usage:
#   rollback.sh              -> lists available backups under ~/.terminal-beauty-backups
#   rollback.sh <backup_dir> -> restores files recorded in that backup's manifest
set -euo pipefail

backup_root="$HOME/.terminal-beauty-backups"

if [ $# -eq 0 ]; then
  if [ -d "$backup_root" ] && [ -n "$(ls -A "$backup_root" 2>/dev/null)" ]; then
    echo "Available backups:"
    ls -1 "$backup_root"
  else
    echo "No backups found in $backup_root"
  fi
  exit 0
fi

backup_dir="$1"
manifest="$backup_dir/manifest.txt"
if [ ! -f "$manifest" ]; then
  echo "No manifest found in $backup_dir" >&2
  exit 1
fi

while IFS=$'\t' read -r base src; do
  [ -z "$base" ] && continue
  if [ "$src" = "defaults:com.googlecode.iterm2" ]; then
    defaults import com.googlecode.iterm2 "$backup_dir/$base"
  else
    rm -rf "$src"
    cp -R "$backup_dir/$base" "$src"
  fi
  echo "restored $src"
done < "$manifest"
