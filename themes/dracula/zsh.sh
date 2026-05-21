# terminal-beauty: Dracula (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;189;147;249:ln=38;2;139;233;253:ex=38;2;80;250;123"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#50fa7b'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8be9fd'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#f8f8f2'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff5555'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
