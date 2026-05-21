# terminal-beauty: Catppuccin Mocha (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;137;180;250:ln=38;2;148;226;213:ex=38;2;166;227;161"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#94e2d5'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
