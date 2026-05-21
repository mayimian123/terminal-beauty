# terminal-beauty: Tokyo Night (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;122;162;247:ln=38;2;125;207;255:ex=38;2;158;206;106"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#9ece6a'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7dcfff'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
