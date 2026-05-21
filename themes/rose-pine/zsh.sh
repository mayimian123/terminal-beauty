# terminal-beauty: Rosé Pine (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;156;207;216:ln=38;2;235;188;186:ex=38;2;49;116;143"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#31748f'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#ebbcba'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#e0def4'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#eb6f92'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
