# terminal-beauty: Gruvbox Dark (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;69;133;136:ln=38;2;104;157;106:ex=38;2;152;151;26"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#98971a'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#689d6a'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#ebdbb2'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#cc241d'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
