# terminal-beauty: Gruvbox Dark (fish)
set -g fish_color_normal ebdbb2
set -g fish_color_command 458588
set -g fish_color_keyword b16286
set -g fish_color_quote 98971a
set -g fish_color_redirection 689d6a
set -g fish_color_end d79921
set -g fish_color_error cc241d
set -g fish_color_param ebdbb2
set -g fish_color_comment 928374
set -g fish_color_selection --background=928374
set -g fish_color_autosuggestion 928374
set -g fish_pager_color_prefix 458588
set -g fish_pager_color_completion ebdbb2

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
