# terminal-beauty

macOS terminal themes for zsh, Starship, fish, and iTerm2, with safe backups
and rollback.

This repo is designed to work as both a Codex/Claude Code skill and a small
theme installer. The product flow is intentionally visual-first: preview the
themes, choose one, then apply only that theme.

## Preview Themes

Open the gallery:

- [Public gallery](https://mayimian123.github.io/terminal-beauty/)
- [index.html](index.html)
- [demo/themes-preview.html](demo/themes-preview.html)
- Static screenshot: ![terminal-beauty theme preview](demo/themes-preview.png)

Available themes:

- `tokyo-night`
- `dracula`
- `nord`
- `catppuccin`
- `gruvbox`
- `rose-pine`
- `everforest`
- `solarized-dark`

## Install A Theme

From this repo:

```bash
scripts/install.sh tokyo-night
```

The installer always creates a backup first under:

```bash
~/.terminal-beauty-backups/
```

Then it applies the selected theme where supported:

- zsh: appends a theme source line to `~/.zshrc`
- Starship: writes `~/.config/starship.toml`
- fish: writes `~/.config/fish/conf.d/terminal-beauty.fish`
- iTerm2: copies the `.itermcolors` preset and prints import instructions

## Roll Back

List backups:

```bash
scripts/rollback.sh
```

Restore one backup:

```bash
scripts/rollback.sh ~/.terminal-beauty-backups/<timestamp>
```

## Skill Usage

When used as a skill, the assistant should:

1. Detect the user's macOS terminal environment.
2. Send the user to the gallery instead of describing every palette in chat.
3. Ask for one theme slug.
4. Run `scripts/install.sh <theme>`.
5. Show the backup path and the iTerm2 import path when relevant.

## Scope

This project intentionally targets macOS. Windows Terminal, PowerShell, WSL,
Warp, Alacritty, and VS Code terminal themes can be supported later, but they
should not complicate the first version.
