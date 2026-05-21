# terminal-beauty: Everforest (fish)
set -g fish_color_normal d3c6aa
set -g fish_color_command 7fbbb3
set -g fish_color_keyword d699b6
set -g fish_color_quote a7c080
set -g fish_color_redirection 83c092
set -g fish_color_end dbbc7f
set -g fish_color_error e67e80
set -g fish_color_param d3c6aa
set -g fish_color_comment 56635f
set -g fish_color_selection --background=56635f
set -g fish_color_autosuggestion 56635f
set -g fish_pager_color_prefix 7fbbb3
set -g fish_pager_color_completion d3c6aa

if command -v starship >/dev/null 2>&1
    starship init fish | source
end
