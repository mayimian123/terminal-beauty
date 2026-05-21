# terminal-beauty

Visual macOS terminal themes for zsh, Starship, fish, and iTerm2, with
automatic backup and rollback.

[Open the theme gallery](https://mayimian123.github.io/terminal-beauty/) ·
[中文说明](#中文说明)

![terminal-beauty theme preview](demo/themes-preview.png)

## Why

Choosing a terminal theme is a visual decision. Reading a list of hex colors is
slow, abstract, and usually not enough to know whether a theme will feel good
in daily use.

`terminal-beauty` separates the experience into two parts:

- a visual gallery for choosing a theme
- a local installer for applying that theme safely

This keeps the assistant workflow lightweight: the user previews themes in the
browser, chooses one slug, and the installer applies only that theme after
creating a backup.

## Quick Start

Preview the themes:

- [Public gallery](https://mayimian123.github.io/terminal-beauty/)

Install a theme from this repo:

```bash
scripts/install.sh tokyo-night
```

Open a new terminal tab, or reload zsh:

```bash
source ~/.zshrc
```

Available themes:

```text
tokyo-night
dracula
nord
catppuccin
gruvbox
rose-pine
everforest
solarized-dark
```

## What Gets Changed

The installer creates a backup first under:

```bash
~/.terminal-beauty-backups/
```

Then it applies the selected theme where supported:

- zsh: appends one managed source line to `~/.zshrc`
- Starship: writes `~/.config/starship.toml`
- fish: writes `~/.config/fish/conf.d/terminal-beauty.fish` when fish is installed
- iTerm2: copies the `.itermcolors` preset and prints import instructions

If you try another theme later, the installer replaces the previous managed
zsh source line instead of stacking duplicate theme entries.

## Rollback

List available backups:

```bash
scripts/rollback.sh
```

Restore one backup:

```bash
scripts/rollback.sh ~/.terminal-beauty-backups/<timestamp>
```

Backups are never deleted by the installer.

## Repository Layout

- `SKILL.md`: the assistant workflow. It tells the assistant to send users to
  the gallery, ask for a theme slug, and run the safe installer.
- `index.html`: the GitHub Pages entrypoint. It redirects the clean public URL
  to the gallery.
- `demo/themes-preview.html`: the actual visual gallery page.
- `demo/themes-preview.png`: a static preview image for GitHub README rendering.
- `scripts/install.sh`: applies one selected theme after backing up current config.
- `scripts/backup.sh`: creates timestamped backups.
- `scripts/rollback.sh`: restores a selected backup.
- `themes/`: curated theme templates for zsh, Starship, fish, and iTerm2.
- `references/`: implementation notes for theme format and custom generation.
- `tests/`: Bats tests for detection, backup, install, rollback, and the core flow.

`index.html` and `demo/themes-preview.html` are both useful: `index.html` gives
GitHub Pages a clean root URL, while `demo/themes-preview.html` keeps the
gallery itself isolated and easy to replace later.

## Using It As A Skill

When this repo is installed as a skill, the assistant should:

1. Detect the user's macOS terminal environment.
2. Open or share the visual gallery instead of describing every palette in chat.
3. Ask the user to choose one theme slug.
4. Run `scripts/install.sh <theme>`.
5. Show the backup path and any iTerm2 import instructions.

The skill intentionally avoids installing tools without explicit user consent.

## Scope

This project is intentionally macOS-first. It is designed for zsh, Starship,
fish, and iTerm2 on macOS.

Windows Terminal, PowerShell, WSL, Warp, Alacritty, and VS Code terminal themes
may be supported later, but they are outside the first version so the core
experience can stay simple and reliable.

## Development

Run the test suite:

```bash
bats tests
```

Check shell syntax:

```bash
bash -n scripts/*.sh
```

---

## 中文说明

`terminal-beauty` 是一个面向 macOS 的终端主题工具，支持 zsh、Starship、
fish 和 iTerm2。它的重点不是在聊天里解释一堆颜色值，而是让用户先通过可视化页面
选择主题，再由本地脚本安全应用。

[打开主题预览页面](https://mayimian123.github.io/terminal-beauty/)

## 为什么做这个

终端主题是一个视觉选择。只看主题名、描述或者 18 个 hex 色值，很难判断它在真实
终端里是否舒服。

所以这个项目把体验拆成两层：

- 用网页 gallery 负责可视化选择
- 用本地 installer 负责安全应用

这样 skill 不需要在对话里反复展示 8 套主题，也不需要用户盲试。用户看完页面后只
要给出主题 slug，脚本就会先备份，再应用选中的主题。

## 快速开始

先看主题：

- [公开预览页面](https://mayimian123.github.io/terminal-beauty/)

在本仓库中安装一个主题：

```bash
scripts/install.sh tokyo-night
```

打开新的终端标签页，或者重新加载 zsh：

```bash
source ~/.zshrc
```

可选主题：

```text
tokyo-night
dracula
nord
catppuccin
gruvbox
rose-pine
everforest
solarized-dark
```

## 会修改什么

安装脚本会先备份当前配置，备份目录在：

```bash
~/.terminal-beauty-backups/
```

然后根据环境应用主题：

- zsh：在 `~/.zshrc` 中写入一行受管理的 theme source
- Starship：写入 `~/.config/starship.toml`
- fish：如果安装了 fish，写入 `~/.config/fish/conf.d/terminal-beauty.fish`
- iTerm2：复制 `.itermcolors` 文件，并提示用户如何导入

如果之后换另一套主题，脚本会替换上一条受管理的 zsh 主题配置，不会无限叠加。

## 回滚

列出已有备份：

```bash
scripts/rollback.sh
```

恢复某个备份：

```bash
scripts/rollback.sh ~/.terminal-beauty-backups/<timestamp>
```

安装脚本不会删除备份。

## 文件结构

- `SKILL.md`：assistant 使用这个 skill 时遵循的流程。
- `index.html`：GitHub Pages 的入口，让公开链接更干净。
- `demo/themes-preview.html`：真正的主题预览页面。
- `demo/themes-preview.png`：README 里展示用的静态预览图。
- `scripts/install.sh`：安装某一个选中的主题，并且先备份。
- `scripts/backup.sh`：创建带时间戳的备份。
- `scripts/rollback.sh`：从某个备份恢复配置。
- `themes/`：内置主题模板。
- `references/`：主题格式和自定义主题生成说明。
- `tests/`：Bats 测试。

`index.html` 和 `demo/themes-preview.html` 不是重复文件。前者负责让 GitHub
Pages 有一个好看的根路径；后者是实际的 gallery 页面。以后如果想重做 gallery，
只需要替换 `demo/themes-preview.html`，公开入口可以保持不变。

## 作为 Skill 使用

当用户说“美化我的 terminal”时，assistant 应该：

1. 检测用户的 macOS 终端环境。
2. 先给主题预览页面，而不是在聊天里展开所有配色。
3. 让用户选择一个主题 slug。
4. 执行 `scripts/install.sh <theme>`。
5. 告诉用户备份路径，以及 iTerm2 的导入路径。

这个 skill 不会在用户没有明确同意时安装新工具。

## 适用范围

当前版本明确面向 macOS，重点支持 zsh、Starship、fish 和 iTerm2。

Windows Terminal、PowerShell、WSL、Warp、Alacritty、VS Code 集成终端等可以
以后再扩展，但不放进第一版，避免把核心体验做复杂。
