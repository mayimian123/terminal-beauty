# terminal-beauty: Tokyo Night (fish)
set -g fish_color_normal c0caf5
set -g fish_color_command 7aa2f7
set -g fish_color_keyword bb9af7
set -g fish_color_quote 9ece6a
set -g fish_color_redirection 7dcfff
set -g fish_color_end e0af68
set -g fish_color_error f7768e
set -g fish_color_param c0caf5
set -g fish_color_comment 414868
set -g fish_color_selection --background=414868
set -g fish_color_autosuggestion 414868
set -g fish_pager_color_prefix 7aa2f7
set -g fish_pager_color_completion c0caf5

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
