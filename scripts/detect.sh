#!/usr/bin/env bash
# Detects the user's terminal environment. Prints key=value lines.
set -euo pipefail

case "${SHELL:-}" in
  */zsh)  shell="zsh" ;;
  */fish) shell="fish" ;;
  */bash) shell="bash" ;;
  *)      shell="unknown" ;;
esac
echo "shell=$shell"

echo "term_program=${TERM_PROGRAM:-unknown}"

if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  echo "oh_my_zsh=yes"
else
  echo "oh_my_zsh=no"
fi

if command -v starship >/dev/null 2>&1; then
  echo "starship=yes"
else
  echo "starship=no"
fi

if command -v fish >/dev/null 2>&1; then
  echo "fish=yes"
else
  echo "fish=no"
fi
