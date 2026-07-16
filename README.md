<div align="center">

# Terminal Beauty

> “See the real result first, then decide whether to install it in your terminal.”

A theme-configuration experiment for the native macOS Terminal that turns “preview → choose → back up → apply → roll back” into a reusable local setup workflow.

It is not a new terminal and is not intended to replace Warp or iTerm2. It is closer to a workflow prototype for Codex / Claude Code:
first let users choose a theme visually on the web, then use local scripts to apply it safely to Apple Terminal, zsh, Starship, fish, and iTerm2.

<p>
  <img alt="macOS" src="https://img.shields.io/badge/macOS-focused-111827?style=flat-square">
  <img alt="Shell" src="https://img.shields.io/badge/shell-zsh%20%7C%20fish-2563eb?style=flat-square">
  <img alt="Themes" src="https://img.shields.io/badge/themes-8-7c3aed?style=flat-square">
  <img alt="Tests" src="https://img.shields.io/badge/tests-bats-059669?style=flat-square">
</p>

[English](#english) ·
[中文](#中文) ·
[Theme Gallery](https://mayimian123.github.io/terminal-beauty/) ·
[30-Second Start](#30-second-start) ·
[Project Status](#project-status) ·
[What It Does](#what-it-does) ·
[Apple Terminal and Starship](#apple-terminal-and-starship) ·
[Custom Styles](#custom-styles) ·
[Safety and Rollback](#safety-and-rollback)

</div>

<a id="english"></a>

---

![terminal-beauty theme preview](demo/themes-preview.png)

---

<details>
<summary><strong>Read before use: which local settings does this project modify?</strong></summary>

The installer automatically creates a backup before applying a theme. Backups are stored at:

```bash
~/.terminal-beauty-backups/
```

It then modifies the following files according to your environment:

- `~/.zshrc`
- `~/.config/starship.toml`
- `~/.config/fish/conf.d/terminal-beauty.fish`
- Apple Terminal profiles can be imported automatically and set as defaults with the user's consent
- iTerm2 `.itermcolors` theme files can be imported optionally

The installer never deletes backups or installs new tools without explicit consent.

</details>

---

## Project Status

The current version is `v1.0.0-beta.1` and is positioned as an **Apple Terminal theming workflow experiment**.

This project is not trying to prove that Apple Terminal has hidden superpowers. It validates this flow:

```text
visual selection page -> local skill execution -> automatic backup -> write configuration -> rollback available
```

This approach works for Terminal theme configuration. However, if your everyday need is simply “a more modern, better-looking terminal experience,” a modern terminal such as Warp may already be the easier option.

This repository will remain as an archived experiment. It still works, but there are currently no plans to expand it into a larger terminal product.

Current capabilities:

- Apple Terminal as the default path
- Starship prompt
- 8 curated themes
- Custom style brief
- Automatic backup, automatic import, and rollback

Windows, VS Code terminal, Warp, Alacritty, cloud sync, and direct browser modification of local configuration are currently out of scope.

---

## What It Does

It replaces “reading theme descriptions in chat, choosing blindly, and repeatedly trying themes” with “preview the result first, then install the one you selected.”

The core flow is:

```text
open theme gallery -> choose a theme name -> automatic backup -> apply theme -> roll back if you do not like it
```

It currently supports:

- zsh: writes one Terminal Beauty-managed theme configuration line
- Starship: replaces `starship.toml`
- fish: writes fish startup configuration
- Apple Terminal: generates an importable `.terminal` profile
- iTerm2: provides an importable `.itermcolors` color preset

## Apple Terminal and Starship

If you use the built-in macOS Terminal, you do not need to install iTerm2 for this project.

The visual result has two layers:

- **Apple Terminal Profile**: controls the window background, text, cursor, and base 16 colors.
- **Starship**: controls the command-line prompt, including segmented styles for the directory, git branch, and execution time.

Apple Terminal + Starship can therefore reproduce the most visible advanced prompt effects in the preview. The generated Apple Terminal profile controls the window colors.

Install Starship:

```bash
brew install starship
```

iTerm2 is an optional path, not a required dependency.

## Why Not Just Provide Eight Templates?

A terminal theme is a visual decision. Theme names and color codes alone make it difficult to judge whether a theme will feel comfortable in a real terminal.

The repository is therefore split into two layers:

- **Gallery**: lets users see realistic terminal previews first
- **Installer**: applies only the selected theme and creates a backup first

When the project is used as a skill, this avoids expanding a long list of color descriptions in the conversation and prevents users from having to test each theme one by one.

## Custom Styles

The theme gallery includes a custom brief generator:

[https://mayimian123.github.io/terminal-beauty/#custom](https://mayimian123.github.io/terminal-beauty/#custom)

You can select a base reference, light or dark mode, overall mood, and required colors. The page generates a brief that can be sent directly to Codex.

After receiving the brief, the skill will:

1. Generate a complete theme template under `themes/_custom/<theme-name>/`.
2. Generate a native Apple Terminal profile.
3. Use the same installation flow to back up, apply, and import profiles.

The browser never modifies local files directly; the skill and local scripts still perform the actual changes.

## 30-Second Start

First, open the theme gallery:

[https://mayimian123.github.io/terminal-beauty/](https://mayimian123.github.io/terminal-beauty/)

Choose a theme name, such as `tokyo-night`, then run this from the repository root:

```bash
scripts/install.sh tokyo-night
```

If you have already decided to open the Apple Terminal profile import window immediately, run:

```bash
scripts/install.sh --open-terminal-profile tokyo-night
```

For the simplest setup, import all Apple Terminal themes at once and set the current theme as the default:

```bash
scripts/install.sh --import-terminal-profiles tokyo-night
```

You can then filter and switch among all Terminal Beauty themes directly in Terminal settings.

Open a new terminal tab or reload zsh:

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

## Safety and Rollback

List existing backups:

```bash
scripts/rollback.sh
```

Restore a backup:

```bash
scripts/rollback.sh ~/.terminal-beauty-backups/<timestamp>
```

If you try several themes in succession, `install.sh` replaces the previous managed zsh configuration instead of endlessly appending lines to `.zshrc`.

After importing an Apple Terminal profile, select it here:

```text
Terminal > Settings > Profiles
```

If you used `--import-terminal-profiles`, the script automatically sets:

```text
Default Window Settings
Startup Window Settings
```

New Terminal windows should then open with the selected theme. Existing windows do not change color automatically and must be reopened.

## Using It as a Skill

When a user says “beautify my terminal,” the assistant should:

1. Detect the user's macOS terminal environment.
2. Share the theme gallery instead of listing every color preset in chat.
3. Ask the user to choose a theme name.
4. If the user wants the prompt effect shown in the previews, install Starship after confirmation.
5. Run `scripts/install.sh <theme>`.
6. Tell the user where the backup was stored.
7. With the user's consent, run `scripts/install.sh --import-terminal-profiles <theme>` to import all Apple Terminal themes and set the default.
8. If the user prefers manual import, open `<theme>.terminal` instead.

The skill is designed to validate a “visual selection + safe local execution” flow while preserving a safe rollback path.

## Project Structure

```text
terminal-beauty/
├── SKILL.md
├── index.html
├── demo/
│   ├── themes-preview.html
│   └── themes-preview.png
├── scripts/
│   ├── detect.sh
│   ├── backup.sh
│   ├── doctor.sh
│   ├── install.sh
│   ├── import_terminal_profiles.py
│   └── rollback.sh
├── themes/
├── references/
└── tests/
```

Files that are easy to confuse:

- `index.html`: the GitHub Pages entry point that keeps the public URL clean.
- `demo/themes-preview.html`: the actual theme gallery.
- `demo/themes-preview.png`: the static preview shown in this README.
- `SKILL.md`: workflow instructions for Codex / Claude Code.
- `themes/*/<theme-name>.terminal`: native Apple Terminal profiles. The filename determines the name shown in Terminal settings after import.
- `scripts/import_terminal_profiles.py`: writes all Apple Terminal profiles into Terminal settings and can set the default theme.
- `scripts/doctor.sh`: checks Starship, the zsh hook, the default Apple Terminal profile, imported themes, and the latest backup.

`index.html` and `demo/themes-preview.html` are not duplicates. The former provides a stable entry point; the latter is the actual gallery. A future gallery redesign only needs to replace `demo/themes-preview.html`.

## Development

Run tests:

```bash
bats tests
```

Check shell syntax:

```bash
bash -n scripts/*.sh
```

## Scope

The current version explicitly targets macOS, supports Apple Terminal by default, focuses on zsh, Starship, and fish, and retains an optional iTerm2 path.

Windows Terminal, PowerShell, WSL, Warp, Alacritty, and the VS Code integrated terminal can be supported later, but they are intentionally excluded from the first version to keep the core experience focused.

---

<a id="中文"></a>

<div align="center">

# Terminal Beauty

> “先看到真实效果，再决定要不要把它装进自己的终端。”

一个面向 macOS 原生 Terminal 的主题配置实验，把「看主题 → 选主题 → 备份 → 应用 → 可回滚」做成一条可复用的本地设置流程。

它不是一个新终端，也不是要替代 Warp / iTerm2。它更像一个给 Codex / Claude Code 使用的 workflow prototype：
先让用户在网页里可视化选择主题，再由本地脚本安全地应用到 Apple Terminal、zsh、Starship、fish 和 iTerm2。

<p>
  <img alt="macOS" src="https://img.shields.io/badge/macOS-focused-111827?style=flat-square">
  <img alt="Shell" src="https://img.shields.io/badge/shell-zsh%20%7C%20fish-2563eb?style=flat-square">
  <img alt="Themes" src="https://img.shields.io/badge/themes-8-7c3aed?style=flat-square">
  <img alt="Tests" src="https://img.shields.io/badge/tests-bats-059669?style=flat-square">
</p>

[主题预览](https://mayimian123.github.io/terminal-beauty/) ·
[30 秒上手](#30-秒上手) ·
[项目状态](#项目状态) ·
[它做了什么](#它做了什么) ·
[Apple Terminal 和 Starship](#apple-terminal-和-starship) ·
[自定义风格](#自定义风格) ·
[安全与回滚](#安全与回滚) ·
[English](#english) ·
[中文](#中文)

</div>

---

![terminal-beauty theme preview](demo/themes-preview.png)

---

<details>
<summary><strong>使用前请阅读：这个项目会修改哪些本地配置？</strong></summary>

安装主题前会自动创建备份，备份位置在：

```bash
~/.terminal-beauty-backups/
```

之后会根据你的环境修改这些文件：

- `~/.zshrc`
- `~/.config/starship.toml`
- `~/.config/fish/conf.d/terminal-beauty.fish`
- Apple Terminal profiles 可在用户同意后自动导入并设置默认
- iTerm2 的 `.itermcolors` 主题文件可选导入

安装脚本不会删除备份，也不会在没有明确同意的情况下安装新工具。

</details>

---

## 项目状态

当前版本停在 `v1.0.0-beta.1`，定位为一个 **Apple Terminal theming workflow experiment**。

这个项目验证的不是“Apple Terminal 有什么隐藏超能力”，而是：

```text
视觉选择网页 -> 本地 skill 执行 -> 自动备份 -> 写入配置 -> 可回滚
```

这套模式对 Terminal 主题配置是可行的，但如果你的日常需求只是“更现代、更好看的终端体验”，Warp 这类现代终端可能已经是更省心的选择。

这个仓库会保留为实验沉淀版。它仍然可用，但暂时不继续扩展为更大的终端产品。

当前能力：

- Apple Terminal 默认路径
- Starship prompt
- 8 套精选主题
- 自定义风格 brief
- 自动备份、自动导入、可回滚

暂不覆盖 Windows、VS Code terminal、Warp、Alacritty、云同步或网页直接修改本地配置。

---

## 它做了什么

把「在聊天里读主题描述、盲选、反复试错」变成「先看效果图，再安装选中的那一套」。

核心流程是：

```text
打开主题预览页 -> 选择主题名 -> 自动备份 -> 应用主题 -> 不喜欢就回滚
```

它目前支持：

- zsh：写入一行由 Terminal Beauty 管理的主题配置
- Starship：替换 `starship.toml`
- fish：写入 fish 启动配置
- Apple Terminal：生成可导入的 `.terminal` profile
- iTerm2：提供可导入的 `.itermcolors` 配色文件

## Apple Terminal 和 Starship

如果你使用的是 macOS 自带的 Terminal，不需要为了这个项目额外下载 iTerm2。

这里有两层效果：

- **Apple Terminal Profile**：控制窗口背景色、文字色、光标色和基础 16 色。
- **Starship**：控制命令行提示符，也就是目录、git 分支、执行时间这些分段样式。

所以，Apple Terminal + Starship 可以实现预览图里最明显的高级 prompt 效果；窗口配色部分由项目生成的 Apple Terminal profile 负责。

安装 Starship：

```bash
brew install starship
```

iTerm2 是可选路径，不是必需依赖。

## 为什么不是只放 8 套模板

终端主题是视觉决策。只看主题名和颜色代码，很难判断它放进真实终端后是否舒服。

所以这个仓库分成两层：

- **Gallery**：让用户先看真实终端预览
- **Installer**：只应用用户选中的主题，并且先备份

这样使用 skill 时不需要在对话里展开一长串配色说明，也不需要用户一套套试。

## 自定义风格

主题预览页里有一个自定义 brief 生成器：

[https://mayimian123.github.io/terminal-beauty/#custom](https://mayimian123.github.io/terminal-beauty/#custom)

你可以选择基础参考、明暗、整体气质和必须出现的颜色。页面会生成一段可以直接发给 Codex 的 brief。

skill 收到 brief 后会：

1. 在 `themes/_custom/<主题名>/` 生成完整主题模板。
2. 生成 Apple Terminal 原生 profile。
3. 通过同一套安装流程备份、应用、导入 profiles。

浏览器不会直接修改本地文件；真正落地仍由 skill 和本地脚本完成。

## 30 秒上手

先打开主题预览：

[https://mayimian123.github.io/terminal-beauty/](https://mayimian123.github.io/terminal-beauty/)

选择一个主题名，例如 `tokyo-night`，然后在仓库根目录运行：

```bash
scripts/install.sh tokyo-night
```

如果你已经决定要立即打开 Apple Terminal profile 导入窗口，可以运行：

```bash
scripts/install.sh --open-terminal-profile tokyo-night
```

更省心的方式是一次性导入全部 Apple Terminal 主题，并把当前主题设成默认：

```bash
scripts/install.sh --import-terminal-profiles tokyo-night
```

这样之后你可以直接在 Terminal 设置里筛选/切换全部 Terminal Beauty 主题。

打开一个新的终端标签页，或者重新加载 zsh：

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

## 安全与回滚

列出已有备份：

```bash
scripts/rollback.sh
```

恢复某个备份：

```bash
scripts/rollback.sh ~/.terminal-beauty-backups/<timestamp>
```

如果你连续试多套主题，`install.sh` 会替换上一条受管理的 zsh 配置，不会在 `.zshrc` 里无限叠加。

Apple Terminal profile 导入后，在这里选择：

```text
Terminal > Settings > Profiles
```

如果使用了 `--import-terminal-profiles`，脚本会自动设置：

```text
Default Window Settings
Startup Window Settings
```

之后新开的 Terminal 窗口应该直接使用选中的主题。已经打开的旧窗口不会自动变色，需要重新打开窗口。

## 作为 Skill 使用

当用户说“美化我的 terminal”时，assistant 应该：

1. 检测用户的 macOS 终端环境。
2. 给出主题预览页，而不是在聊天里展开所有配色。
3. 让用户选择一个主题名。
4. 如果用户需要预览图里的 prompt 效果，确认后安装 Starship。
5. 执行 `scripts/install.sh <theme>`。
6. 告诉用户备份路径。
7. 如果用户同意，执行 `scripts/install.sh --import-terminal-profiles <theme>`，一次性导入全部 Apple Terminal 主题并设置默认。
8. 如果用户偏好手动导入，再打开 `<theme>.terminal`。

这个 skill 的重点是验证“可视化选择 + 本地安全执行”的流程，同时保留安全回滚路径。

## 项目结构

```text
terminal-beauty/
├── SKILL.md
├── index.html
├── demo/
│   ├── themes-preview.html
│   └── themes-preview.png
├── scripts/
│   ├── detect.sh
│   ├── backup.sh
│   ├── doctor.sh
│   ├── install.sh
│   ├── import_terminal_profiles.py
│   └── rollback.sh
├── themes/
├── references/
└── tests/
```

几个容易混淆的文件：

- `index.html`：GitHub Pages 入口，让公开链接保持干净。
- `demo/themes-preview.html`：真正的主题预览页面。
- `demo/themes-preview.png`：README 里展示用的静态图。
- `SKILL.md`：给 Codex / Claude Code 读取的工作流说明。
- `themes/*/<主题名>.terminal`：Apple Terminal 原生 profile。文件名会影响导入后在 Terminal 设置里显示的名称。
- `scripts/import_terminal_profiles.py`：把全部 Apple Terminal profiles 写入 Terminal 设置，并可设置默认主题。
- `scripts/doctor.sh`：检查 Starship、zsh hook、Apple Terminal 默认 profile、导入主题和最近备份。

`index.html` 和 `demo/themes-preview.html` 不是重复文件。前者负责稳定入口，后者负责实际 gallery。以后重做预览页，只需要替换 `demo/themes-preview.html`。

## 开发

运行测试：

```bash
bats tests
```

检查 shell 语法：

```bash
bash -n scripts/*.sh
```

## 适用范围

当前版本明确面向 macOS，默认支持 Apple Terminal，重点支持 zsh、Starship、fish，也保留 iTerm2 可选路径。

Windows Terminal、PowerShell、WSL、Warp、Alacritty、VS Code 集成终端等可以以后再扩展，但不放进第一版，避免把核心体验做复杂。
