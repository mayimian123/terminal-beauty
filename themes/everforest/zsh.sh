# terminal-beauty: Everforest (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;127;187;179:ln=38;2;131;192;146:ex=38;2;167;192;128"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#a7c080'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#83c092'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#d3c6aa'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e67e80'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
