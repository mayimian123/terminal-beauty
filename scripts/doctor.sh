#!/usr/bin/env bash
# Prints a quick health report for Terminal Beauty on macOS.
set -euo pipefail

status() {
  printf '%-28s %s\n' "$1" "$2"
}

echo "Terminal Beauty doctor"
echo

if [ "$(uname -s)" = "Darwin" ]; then
  status "macOS" "yes"
else
  status "macOS" "no"
fi

case "${SHELL:-}" in
  */zsh) status "shell" "zsh" ;;
  */fish) status "shell" "fish" ;;
  */bash) status "shell" "bash" ;;
  *) status "shell" "${SHELL:-unknown}" ;;
esac

if command -v starship >/dev/null 2>&1; then
  status "Starship" "$(starship --version | head -1)"
else
  status "Starship" "missing; install with: brew install starship"
fi

if [ -f "$HOME/.zshrc" ] && grep -q "terminal-beauty" "$HOME/.zshrc"; then
  status "zsh theme hook" "installed"
else
  status "zsh theme hook" "not found"
fi

if [ -f "$HOME/.config/starship.toml" ] && grep -q "terminal-beauty" "$HOME/.config/starship.toml"; then
  status "Starship config" "$HOME/.config/starship.toml"
else
  status "Starship config" "not found"
fi

if defaults read com.apple.Terminal >/dev/null 2>&1; then
  default_profile="$(defaults read com.apple.Terminal 'Default Window Settings' 2>/dev/null || true)"
  startup_profile="$(defaults read com.apple.Terminal 'Startup Window Settings' 2>/dev/null || true)"
  status "Apple Terminal default" "${default_profile:-not set}"
  status "Apple Terminal startup" "${startup_profile:-not set}"

  imported_profiles="$(
    defaults read com.apple.Terminal 'Window Settings' 2>/dev/null \
      | grep -E '^[[:space:]]*\"?(tokyo-night|dracula|nord|catppuccin|gruvbox|rose-pine|everforest|solarized-dark)\"? = ' \
      | sed -E 's/^[[:space:]]*"?([^" =]+)"?.*/\1/' \
      | tr '\n' ' '
  )"
  status "Imported TB profiles" "${imported_profiles:-none}"

  if defaults read com.apple.Terminal 'Window Settings' 2>/dev/null | grep -q '^[[:space:]]*terminal ='; then
    status "Legacy profile" "found: terminal; safe to delete manually if it came from an old Terminal Beauty import"
  else
    status "Legacy profile" "none"
  fi
else
  status "Apple Terminal prefs" "not found"
fi

if [ -d "$HOME/.terminal-beauty-backups" ]; then
  latest_backup="$(find "$HOME/.terminal-beauty-backups" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)"
  status "Latest backup" "${latest_backup:-none}"
else
  status "Latest backup" "none"
fi
