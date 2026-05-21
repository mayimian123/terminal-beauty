#!/usr/bin/env bash
# Applies one terminal-beauty theme on macOS.
# Usage: install.sh <theme-name>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
THEMES_DIR="$ROOT_DIR/themes"
THEME_NAME="${1:-}"

usage() {
  cat <<EOF
Usage: scripts/install.sh <theme-name>

Available themes:
$(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '_custom' -exec basename {} \; | sort | sed 's/^/  - /')
EOF
}

if [ -z "$THEME_NAME" ] || [ "$THEME_NAME" = "-h" ] || [ "$THEME_NAME" = "--help" ]; then
  usage
  exit 0
fi

case "$(uname -s)" in
  Darwin) ;;
  *)
    echo "terminal-beauty currently supports macOS only." >&2
    exit 1
    ;;
esac

case "$THEME_NAME" in
  *[!a-zA-Z0-9._-]*)
    echo "Invalid theme name: $THEME_NAME" >&2
    exit 1
    ;;
esac

THEME_DIR="$THEMES_DIR/$THEME_NAME"
if [ ! -d "$THEME_DIR" ]; then
  echo "Unknown theme: $THEME_NAME" >&2
  usage >&2
  exit 1
fi

BACKUP_DIR="$("$SCRIPT_DIR/backup.sh")"
echo "Backup created: $BACKUP_DIR"

INSTALL_ROOT="$HOME/.terminal-beauty"
INSTALLED_THEME_DIR="$INSTALL_ROOT/themes/$THEME_NAME"
mkdir -p "$INSTALL_ROOT/themes" "$HOME/.config"
rm -rf "$INSTALLED_THEME_DIR"
cp -R "$THEME_DIR" "$INSTALLED_THEME_DIR"

if [ -f "$INSTALLED_THEME_DIR/zsh.sh" ]; then
  ZSHRC="$HOME/.zshrc"
  SOURCE_LINE="source \"$INSTALLED_THEME_DIR/zsh.sh\""
  touch "$ZSHRC"
  tmp_zshrc="$(mktemp)"
  awk '
    /^# terminal-beauty:/ { skip_next=1; next }
    skip_next && /^source ".*\/\.terminal-beauty\/themes\/.*\/zsh\.sh"$/ { skip_next=0; next }
    /^source .*\/\.claude\/skills\/terminal-beauty\/themes\/.*\/zsh\.sh"?$/ { next }
    /^source "?.*\/\.codex\/skills\/terminal-beauty\/themes\/.*\/zsh\.sh"?$/ { next }
    /^source "?.*\/Desktop\/terminal-beauty\/themes\/.*\/zsh\.sh"?$/ { next }
    { skip_next=0; print }
  ' "$ZSHRC" > "$tmp_zshrc"
  mv "$tmp_zshrc" "$ZSHRC"
  if ! grep -Fqx "$SOURCE_LINE" "$ZSHRC"; then
    {
      printf '\n# terminal-beauty: %s\n' "$THEME_NAME"
      printf '%s\n' "$SOURCE_LINE"
    } >> "$ZSHRC"
  fi
  echo "Updated: $ZSHRC"
fi

if [ -f "$INSTALLED_THEME_DIR/starship.toml" ]; then
  cp "$INSTALLED_THEME_DIR/starship.toml" "$HOME/.config/starship.toml"
  echo "Updated: $HOME/.config/starship.toml"
  if ! command -v starship >/dev/null 2>&1; then
    echo "Note: Starship is not installed, so the prompt config will take effect after you install it:"
    echo "  brew install starship"
  fi
fi

if command -v fish >/dev/null 2>&1 && [ -f "$INSTALLED_THEME_DIR/fish.fish" ]; then
  mkdir -p "$HOME/.config/fish/conf.d"
  cp "$INSTALLED_THEME_DIR/fish.fish" "$HOME/.config/fish/conf.d/terminal-beauty.fish"
  echo "Updated: $HOME/.config/fish/conf.d/terminal-beauty.fish"
fi

if [ "${TERM_PROGRAM:-}" = "iTerm.app" ] && [ -f "$INSTALLED_THEME_DIR/iterm.itermcolors" ]; then
  echo "iTerm2 color preset ready: $INSTALLED_THEME_DIR/iterm.itermcolors"
  echo "Import it in iTerm2: Settings > Profiles > Colors > Color Presets > Import."
elif [ -f "$INSTALLED_THEME_DIR/iterm.itermcolors" ]; then
  echo "iTerm2 preset copied for later use: $INSTALLED_THEME_DIR/iterm.itermcolors"
  if [ "${TERM_PROGRAM:-}" = "Apple_Terminal" ]; then
    echo "Apple Terminal note: Starship controls the prompt style; Terminal Profiles control the window colors."
  fi
fi

echo "Theme applied: $THEME_NAME"
echo "Open a new terminal tab, or run: source ~/.zshrc"
