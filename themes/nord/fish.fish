# terminal-beauty: Nord (fish)
set -g fish_color_normal d8dee9
set -g fish_color_command 81a1c1
set -g fish_color_keyword b48ead
set -g fish_color_quote a3be8c
set -g fish_color_redirection 88c0d0
set -g fish_color_end ebcb8b
set -g fish_color_error bf616a
set -g fish_color_param d8dee9
set -g fish_color_comment 4c566a
set -g fish_color_selection --background=4c566a
set -g fish_color_autosuggestion 4c566a
set -g fish_pager_color_prefix 81a1c1
set -g fish_pager_color_completion d8dee9

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
