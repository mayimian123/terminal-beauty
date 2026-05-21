# terminal-beauty —— 设计文档

日期：2026-05-21

## 一句话目标

做一个 Claude Code skill，帮用户美化自己的 terminal：检测环境 → 展示适配的视觉风格 → 应用到真实终端 → 不满意可随时切换或回滚。

## 背景与定位

用户想要一个「让 terminal 变好看、可自定义编辑」的工具，最终确定形态为一个 **skill**（superpowers 风格的 Markdown 指令文件，可附带数据文件和脚本）。

skill 的本质是一份 `SKILL.md` 指令，由 Claude 加载后follow。本项目在此基础上附带主题库数据文件和安全脚本。

## 范围

支持的工具：
- **zsh**（含 Oh My Zsh 主题/插件）
- **Starship** 提示符
- **iTerm2** 配色方案
- **fish shell**

不在范围内（明确告知用户手动处理）：Warp、Alacritty、Terminal.app 配色、VS Code 集成终端等其他终端的配色部分。

## 触发时机

skill 的 `description` 应覆盖以下场景：用户说「美化我的 terminal」「terminal 太丑了」「换个 terminal 主题」「帮我配置 terminal 外观」「make my terminal pretty」「customize my terminal」等。

## 文件结构

```
terminal-beauty/
├── SKILL.md                    # 主流程指令（加载时只读这个，轻量）
├── themes/                     # 精选主题库，每套一个目录
│   ├── tokyo-night/
│   │   ├── theme.md            # 描述 + 配色板 + 预览说明
│   │   ├── zsh.sh              # 注入 .zshrc 的片段
│   │   ├── starship.toml       # Starship 配置
│   │   ├── iterm.itermcolors   # iTerm2 配色文件
│   │   └── fish.fish           # fish 配置片段
│   ├── dracula/   ...
│   ├── nord/      ...
│   ├── catppuccin/ ...
│   ├── gruvbox/   ...
│   ├── rose-pine/ ...
│   ├── everforest/ ...
│   ├── solarized-dark/ ...
│   └── _custom/                # 定制生成的临时主题放这里
├── scripts/
│   ├── detect.sh               # 检测 shell / 终端 App / 已装工具
│   ├── backup.sh               # 备份当前所有相关配置
│   └── rollback.sh             # 从备份恢复
└── references/
    └── custom-theme-guide.md   # 「按描述定制生成」时 Claude 参考的指南
```

加载 skill 时 Claude 只读 `SKILL.md` 以节省 context；需要某套主题时才读对应目录的文件。

## 精选主题库（8 套）

经社区验证、流行的配色方案：

1. Tokyo Night
2. Dracula
3. Nord
4. Catppuccin（Mocha 变体）
5. Gruvbox
6. Rosé Pine
7. Everforest
8. Solarized Dark

每套主题目录包含：
- `theme.md` —— 风格描述、16 色配色板（hex）、适合什么人/场景
- `zsh.sh` —— 注入 `.zshrc` 的片段（Oh My Zsh 主题选择、颜色变量等）
- `starship.toml` —— 完整 Starship 配置
- `iterm.itermcolors` —— iTerm2 配色文件（plist XML）
- `fish.fish` —— fish 配置片段

## 工作流程（SKILL.md 指导 Claude 执行）

1. **检测环境** —— 跑 `detect.sh`，得到：shell 类型（zsh / fish）、终端 App（iTerm2 / Terminal.app / 其他）、是否装 Oh My Zsh、是否装 Starship、是否装 fish。

2. **展示主题** —— 根据检测结果列出适配该环境的精选主题（名称 + 配色板 + 一句话风格描述）。同时提示用户：不喜欢可以描述想要的风格，由 Claude 定制。

3. **用户选择** —— 用户选一套精选主题，或描述定制需求（如「暖色复古风」）。定制时 Claude 参考 `references/custom-theme-guide.md` 现场生成一套新主题，临时写进 `themes/_custom/`，后续流程与精选主题一致。

4. **备份** —— 跑 `backup.sh`，把当前所有相关配置存到 `~/.terminal-beauty-backups/<时间戳>/`，打印备份位置。每次应用前都备份，备份永不删除。

5. **应用** —— Claude 根据选中主题目录里的文件，改写用户的配置（编辑 `.zshrc`、写入 `starship.toml`、放置 fish 配置等）。

6. **看效果** —— 告诉用户怎么看到结果：开新终端标签 / `source ~/.zshrc` / iTerm2 导入配色的步骤。

7. **迭代** —— 用户可「换一套」（回到第 3 步重选并重新备份+应用）或「不喜欢，恢复」（跑 `rollback.sh`）。

## 安全脚本

### detect.sh
输出结构化结果供 Claude 读取：
- shell 类型（读 `$SHELL` / 检查进程）
- `$TERM_PROGRAM`（识别 iTerm2 / Apple Terminal / 其他）
- Oh My Zsh 目录（`~/.oh-my-zsh`）是否存在
- `which starship`、`which fish` 结果

### backup.sh
- 接收一个时间戳目录参数
- 把存在的配置文件逐个复制进去：`.zshrc`、`~/.config/starship.toml`、`~/.config/fish/`、iTerm2 偏好
- iTerm2 配色无法用单文件备份，先用 `defaults export com.googlecode.iterm2` 导出当前偏好
- 写一份 `manifest.txt`，记录每个备份文件对应的原始路径
- 不存在的文件跳过，不记入 manifest

### rollback.sh
- 列出 `~/.terminal-beauty-backups/` 下所有备份目录让用户选
- 按选中备份的 `manifest.txt` 把文件恢复回原位
- 没有任何备份时，友好提示「还没有备份记录」

## iTerm2 的特殊处理

iTerm2 配色不能靠改配置文件直接生效。方案：生成 `.itermcolors` 文件 + 引导用户在 iTerm2 偏好里导入；或使用 iTerm2 的 Dynamic Profiles（放入 `~/Library/Application Support/iTerm2/DynamicProfiles/` 自动加载）。`SKILL.md` 中写清楚两种方式的操作指引。

## 边界情况

- **缺工具**：选的主题需要 Starship 但用户没装 → 提示「需要 `brew install starship`，要装吗？」，用户同意才装，绝不强制。
- **不支持的终端**：检测到非 iTerm2 / 非 Terminal.app（如 Warp、Alacritty）→ 仍处理 shell / Starship 部分，配色部分告知用户该终端需手动设置。
- **全新环境**：`.zshrc` 等配置文件不存在 → 直接新建；备份步骤跳过不存在的文件。
- **rollback 时没有备份**：友好提示「还没有备份记录」。
- **定制主题**：生成的临时主题放 `themes/_custom/`，应用与回滚流程和精选主题完全一致。

## 测试策略

- **脚本单元测试**：detect / backup / rollback 各写测试，在临时目录验证 —— 备份正确复制、manifest 准确、rollback 精确还原。
- **端到端测试**：在干净的临时 HOME 里跑「检测 → 备份 → 应用某主题 → 回滚」，确认配置文件回到原样。
- **触发准确性**：用 `skill-creator` 的 eval 功能验证 `description` 在该触发时触发、不该触发时不触发。

## 设计原则

- 用户的原配置绝对安全：危险操作（动 `.zshrc` 等）由确定性脚本负责备份/回滚，不靠 Claude 临场判断。
- 不强制安装：缺工具时征求同意。
- 加载轻量：`SKILL.md` 只写流程，主题数据按需读取。
