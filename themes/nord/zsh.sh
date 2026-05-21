# terminal-beauty: Nord (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;129;161;193:ln=38;2;136;192;208:ex=38;2;163;190;140"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#a3be8c'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#88c0d0'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#d8dee9'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#bf616a'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
