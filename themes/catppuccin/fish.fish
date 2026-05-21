# terminal-beauty: Catppuccin Mocha (fish)
set -g fish_color_normal cdd6f4
set -g fish_color_command 89b4fa
set -g fish_color_keyword f5c2e7
set -g fish_color_quote a6e3a1
set -g fish_color_redirection 94e2d5
set -g fish_color_end f9e2af
set -g fish_color_error f38ba8
set -g fish_color_param cdd6f4
set -g fish_color_comment 585b70
set -g fish_color_selection --background=585b70
set -g fish_color_autosuggestion 585b70
set -g fish_pager_color_prefix 89b4fa
set -g fish_pager_color_completion cdd6f4

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
