---
name: terminal-beauty
description: Use when the user wants to make their terminal look better — beautify, restyle, or theme their terminal. Triggers on "美化我的 terminal", "terminal 太丑了", "换个 terminal 主题", "帮我配置 terminal 外观", "make my terminal pretty", "customize my terminal", "terminal theme". Detects the environment, applies a curated or custom color theme, and supports safe rollback.
---

# terminal-beauty

Beautify the user's terminal by applying a color theme to zsh, Starship,
iTerm2, and/or fish — with a guaranteed-safe backup and rollback path.

## Workflow

Follow these steps in order. Do not skip the backup step.

### 1. Detect the environment
Run `scripts/detect.sh` and read the `key=value` output: which shell, which
terminal app, whether Oh My Zsh / Starship / fish are installed.

### 2. Present themes
List the curated themes from `themes/` that fit the detected environment.
For each, read its `theme.md` and show the display name, the one-line style
description, and the palette. Tell the user they can also describe a custom
look instead.

Curated themes: tokyo-night, dracula, nord, catppuccin, gruvbox, rose-pine,
everforest, solarized-dark.

### 3. Get the user's choice
The user picks a curated theme, or describes a custom one. For a custom
theme, follow `references/custom-theme-guide.md` to generate it into
`themes/_custom/<slug>/`, then continue as if it were curated.

### 4. Back up the current config
Run `scripts/backup.sh`. It prints the backup directory path — show this
path to the user so they know their original config is safe.

### 5. Apply the theme
From the chosen theme directory, apply each file the environment supports:
- **zsh**: append `source <theme>/zsh.sh` to `~/.zshrc` if not already there.
- **Starship**: copy `<theme>/starship.toml` to `~/.config/starship.toml`.
  If Starship is not installed, offer `brew install starship` — only install
  with the user's consent.
- **fish**: copy `<theme>/fish.fish` to `~/.config/fish/conf.d/terminal-beauty.fish`.
- **iTerm2**: tell the user to import `<theme>/iterm.itermcolors` via
  iTerm2 → Settings → Profiles → Colors → Color Presets → Import, then
  select the imported preset. (Alternatively, copy it into
  `~/Library/Application Support/iTerm2/DynamicProfiles/` as a profile.)

For an unsupported terminal (not iTerm2 / Apple Terminal), apply the shell
and Starship parts and tell the user the color preset must be set manually.

### 6. Show the user how to see it
Tell them to open a new terminal tab/window, or run `source ~/.zshrc`
(zsh) / `exec fish` (fish), and to select the iTerm2 preset if applicable.

### 7. Iterate
- "Try another" → go back to step 3 (run backup.sh again first).
- "Undo / restore" → run `scripts/rollback.sh` with no arguments to list
  backups, ask the user which to restore, then run
  `scripts/rollback.sh <backup_dir>`.

## Safety rules
- Always run `backup.sh` before `apply` — every single time.
- Never delete anything under `~/.terminal-beauty-backups/`.
- Never install a tool without the user's explicit consent.
