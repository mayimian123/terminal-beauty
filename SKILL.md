---
name: terminal-beauty
description: Use when the user wants to make their macOS terminal look better — beautify, restyle, or theme their terminal. Triggers on "美化我的 terminal", "terminal 太丑了", "换个 terminal 主题", "帮我配置 terminal 外观", "make my terminal pretty", "customize my terminal", "terminal theme". Directs the user to a visual theme gallery, applies the selected curated or custom theme, and supports safe rollback.
---

# terminal-beauty

Beautify the user's macOS terminal by applying a color theme to zsh,
Starship, iTerm2, and/or fish — with a guaranteed-safe backup and rollback
path.

## Workflow

Follow these steps in order. Do not skip the backup step.

### 1. Detect the environment
Run `scripts/detect.sh` and read the `key=value` output: which shell, which
terminal app, whether Oh My Zsh / Starship / fish are installed.

This skill is intentionally macOS-first. If the user is on Windows or Linux,
explain that this version targets macOS and do not attempt to apply files.

### 2. Present themes
Send the user to the visual gallery instead of listing every palette in chat:
`demo/themes-preview.html` when running locally, or the project's GitHub Pages
gallery once a public URL exists.

Show only the curated theme slugs and a short prompt to pick one. Do not dump
all 18-color palettes unless the user asks for details.

Curated themes: tokyo-night, dracula, nord, catppuccin, gruvbox, rose-pine,
everforest, solarized-dark.

### 3. Get the user's choice
The user picks a curated theme, or describes a custom one. For a custom
theme, follow `references/custom-theme-guide.md` to generate it into
`themes/_custom/<slug>/`, then continue as if it were curated.

### 4. Apply with the installer
Run `scripts/install.sh <theme-slug>`. The installer performs the mandatory
backup first, then applies the selected theme:
- **zsh**: appends a source line to `~/.zshrc` if not already present.
- **Starship**: copies `starship.toml` to `~/.config/starship.toml`.
- **fish**: copies `fish.fish` to `~/.config/fish/conf.d/terminal-beauty.fish`
  when fish is installed.
- **iTerm2**: copies the `.itermcolors` preset and prints import instructions.

Show the backup directory path printed by the installer so the user knows
their original config is safe.

For an unsupported terminal (not iTerm2 / Apple Terminal), apply the shell
and Starship parts and tell the user the color preset must be set manually.

### 5. Show the user how to see it
Tell them to open a new terminal tab/window, or run `source ~/.zshrc`
(zsh) / `exec fish` (fish), and to select the iTerm2 preset if applicable.

### 6. Iterate
- "Try another" → go back to step 3 and run `scripts/install.sh <theme-slug>`
  again. It backs up every time.
- "Undo / restore" → run `scripts/rollback.sh` with no arguments to list
  backups, ask the user which to restore, then run
  `scripts/rollback.sh <backup_dir>`.

## Safety rules
- Always use `scripts/install.sh` for curated themes so backup happens first.
- Never delete anything under `~/.terminal-beauty-backups/`.
- Never install a tool without the user's explicit consent.
