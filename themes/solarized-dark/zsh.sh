# terminal-beauty: Solarized Dark (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;38;139;210:ln=38;2;42;161;152:ex=38;2;133;153;0"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#859900'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#2aa198'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#839496'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#dc322f'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
