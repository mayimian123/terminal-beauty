# terminal-beauty: Dracula (fish)
set -g fish_color_normal f8f8f2
set -g fish_color_command bd93f9
set -g fish_color_keyword ff79c6
set -g fish_color_quote 50fa7b
set -g fish_color_redirection 8be9fd
set -g fish_color_end f1fa8c
set -g fish_color_error ff5555
set -g fish_color_param f8f8f2
set -g fish_color_comment 6272a4
set -g fish_color_selection --background=6272a4
set -g fish_color_autosuggestion 6272a4
set -g fish_pager_color_prefix bd93f9
set -g fish_pager_color_completion f8f8f2

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
