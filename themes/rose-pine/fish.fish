# terminal-beauty: Rosé Pine (fish)
set -g fish_color_normal e0def4
set -g fish_color_command 9ccfd8
set -g fish_color_keyword c4a7e7
set -g fish_color_quote 31748f
set -g fish_color_redirection ebbcba
set -g fish_color_end f6c177
set -g fish_color_error eb6f92
set -g fish_color_param e0def4
set -g fish_color_comment 6e6a86
set -g fish_color_selection --background=6e6a86
set -g fish_color_autosuggestion 6e6a86
set -g fish_pager_color_prefix 9ccfd8
set -g fish_pager_color_completion e0def4

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
