# terminal-beauty: Solarized Dark (fish)
set -g fish_color_normal 839496
set -g fish_color_command 268bd2
set -g fish_color_keyword d33682
set -g fish_color_quote 859900
set -g fish_color_redirection 2aa198
set -g fish_color_end b58900
set -g fish_color_error dc322f
set -g fish_color_param 839496
set -g fish_color_comment 002b36
set -g fish_color_selection --background=002b36
set -g fish_color_autosuggestion 002b36
set -g fish_pager_color_prefix 268bd2
set -g fish_pager_color_completion 839496

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
