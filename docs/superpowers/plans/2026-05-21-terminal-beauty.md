# terminal-beauty Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code skill (`terminal-beauty`) that detects a user's terminal environment, presents adapted color themes, applies them to the real terminal, and rolls back safely.

**Architecture:** A `SKILL.md` workflow file drives Claude. Three deterministic shell scripts handle the risky parts (environment detection, config backup, rollback). A theme library holds 8 curated themes, each a directory of ready-to-apply config files. A reference guide lets Claude generate custom themes on demand.

**Tech Stack:** Bash (scripts), `bats-core` (shell test framework), TOML (Starship config), plist XML (iTerm2 colors), Markdown (skill + theme metadata).

---

## File Structure

```
terminal-beauty/
├── SKILL.md                       # workflow Claude follows (Task 11)
├── themes/
│   ├── tokyo-night/               # complete worked example (Task 6)
│   │   ├── theme.md
│   │   ├── zsh.sh
│   │   ├── starship.toml
│   │   ├── iterm.itermcolors
│   │   └── fish.fish
│   ├── dracula/                   # Task 7
│   ├── nord/                      # Task 7
│   ├── catppuccin/                # Task 7
│   ├── gruvbox/                   # Task 8
│   ├── rose-pine/                 # Task 8
│   ├── everforest/                # Task 9
│   └── solarized-dark/            # Task 9
├── scripts/
│   ├── detect.sh                  # Task 2
│   ├── backup.sh                  # Task 3
│   └── rollback.sh                # Task 4
├── references/
│   ├── theme-format.md            # Task 6
│   └── custom-theme-guide.md      # Task 10
└── tests/
    ├── test_helper.bash           # Task 1
    ├── detect.bats                # Task 2
    ├── backup.bats                # Task 3
    ├── rollback.bats              # Task 4
    └── e2e.bats                   # Task 5
```

Each theme directory has one responsibility (one color scheme, all four tools). Each script has one responsibility. `SKILL.md` only describes the workflow and stays small so loading the skill is cheap.

---

## Task 1: Project setup

**Files:**
- Create: `tests/test_helper.bash`

- [ ] **Step 1: Install the bats test framework**

Run: `brew install bats-core`
Expected: bats installed. Verify with `bats --version` (prints e.g. `Bats 1.x`).

- [ ] **Step 2: Create the directory skeleton**

Run:
```bash
mkdir -p themes scripts references tests
```
Expected: four directories created at the repo root.

- [ ] **Step 3: Write the shared test helper**

Create `tests/test_helper.bash`:
```bash
# Shared helpers for bats tests.

# Create an isolated fake HOME for a test and cd into a temp workdir.
setup_sandbox() {
  SANDBOX="$(mktemp -d)"
  FAKE_HOME="$SANDBOX/home"
  mkdir -p "$FAKE_HOME"
  export FAKE_HOME SANDBOX
}

teardown_sandbox() {
  [ -n "${SANDBOX:-}" ] && rm -rf "$SANDBOX"
}

# Absolute path to the scripts directory regardless of cwd.
scripts_dir() {
  cd "$BATS_TEST_DIRNAME/../scripts" && pwd
}
```

- [ ] **Step 4: Commit**

```bash
git add tests/test_helper.bash
git commit -m "chore: add test skeleton and bats helper"
```

---

## Task 2: detect.sh — environment detection

**Files:**
- Create: `scripts/detect.sh`
- Test: `tests/detect.bats`

- [ ] **Step 1: Write the failing test**

Create `tests/detect.bats`:
```bash
load test_helper

setup() { setup_sandbox; }
teardown() { teardown_sandbox; }

@test "detect.sh emits all five keys" {
  run env SHELL=/bin/zsh TERM_PROGRAM=iTerm.app HOME="$FAKE_HOME" \
    bash "$(scripts_dir)/detect.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"shell="* ]]
  [[ "$output" == *"term_program="* ]]
  [[ "$output" == *"oh_my_zsh="* ]]
  [[ "$output" == *"starship="* ]]
  [[ "$output" == *"fish="* ]]
}

@test "detect.sh identifies zsh" {
  run env SHELL=/usr/bin/zsh TERM_PROGRAM=Apple_Terminal HOME="$FAKE_HOME" \
    bash "$(scripts_dir)/detect.sh"
  [[ "$output" == *"shell=zsh"* ]]
}

@test "detect.sh reports oh_my_zsh=yes when directory exists" {
  mkdir -p "$FAKE_HOME/.oh-my-zsh"
  run env SHELL=/bin/zsh TERM_PROGRAM=iTerm.app HOME="$FAKE_HOME" \
    bash "$(scripts_dir)/detect.sh"
  [[ "$output" == *"oh_my_zsh=yes"* ]]
}

@test "detect.sh reports oh_my_zsh=no when directory absent" {
  run env SHELL=/bin/zsh TERM_PROGRAM=iTerm.app HOME="$FAKE_HOME" \
    bash "$(scripts_dir)/detect.sh"
  [[ "$output" == *"oh_my_zsh=no"* ]]
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/detect.bats`
Expected: FAIL — `detect.sh` does not exist.

- [ ] **Step 3: Write detect.sh**

Create `scripts/detect.sh`:
```bash
#!/usr/bin/env bash
# Detects the user's terminal environment. Prints key=value lines.
set -euo pipefail

case "${SHELL:-}" in
  */zsh)  shell="zsh" ;;
  */fish) shell="fish" ;;
  */bash) shell="bash" ;;
  *)      shell="unknown" ;;
esac
echo "shell=$shell"

echo "term_program=${TERM_PROGRAM:-unknown}"

if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  echo "oh_my_zsh=yes"
else
  echo "oh_my_zsh=no"
fi

if command -v starship >/dev/null 2>&1; then
  echo "starship=yes"
else
  echo "starship=no"
fi

if command -v fish >/dev/null 2>&1; then
  echo "fish=yes"
else
  echo "fish=no"
fi
```

- [ ] **Step 4: Make it executable**

Run: `chmod +x scripts/detect.sh`

- [ ] **Step 5: Run test to verify it passes**

Run: `bats tests/detect.bats`
Expected: PASS — 4 tests.

- [ ] **Step 6: Commit**

```bash
git add scripts/detect.sh tests/detect.bats
git commit -m "feat: add environment detection script"
```

---

## Task 3: backup.sh — config backup

**Files:**
- Create: `scripts/backup.sh`
- Test: `tests/backup.bats`

- [ ] **Step 1: Write the failing test**

Create `tests/backup.bats`:
```bash
load test_helper

setup() { setup_sandbox; }
teardown() { teardown_sandbox; }

@test "backup.sh copies existing files and writes a manifest" {
  echo "original zshrc" > "$FAKE_HOME/.zshrc"
  mkdir -p "$FAKE_HOME/.config"
  echo "original starship" > "$FAKE_HOME/.config/starship.toml"

  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/backup.sh" "$SANDBOX/backups"
  [ "$status" -eq 0 ]

  dest="$output"
  [ -d "$dest" ]
  [ -f "$dest/manifest.txt" ]
  grep -q ".zshrc" "$dest/manifest.txt"
  grep -q "starship.toml" "$dest/manifest.txt"
}

@test "backup.sh skips files that do not exist" {
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/backup.sh" "$SANDBOX/backups"
  [ "$status" -eq 0 ]
  dest="$output"
  [ -f "$dest/manifest.txt" ]
  # No .zshrc in fake home, so manifest must not mention it.
  ! grep -q ".zshrc" "$dest/manifest.txt"
}

@test "backed-up file content matches the original" {
  echo "hello terminal" > "$FAKE_HOME/.zshrc"
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/backup.sh" "$SANDBOX/backups"
  dest="$output"
  base="$(cut -f1 "$dest/manifest.txt" | head -1)"
  [ "$(cat "$dest/$base")" = "hello terminal" ]
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/backup.bats`
Expected: FAIL — `backup.sh` does not exist.

- [ ] **Step 3: Write backup.sh**

Create `scripts/backup.sh`:
```bash
#!/usr/bin/env bash
# Backs up terminal config files into a timestamped directory.
# Usage: backup.sh [backup_root]   (default: ~/.terminal-beauty-backups)
# Prints the created backup directory path on stdout.
set -euo pipefail

backup_root="${1:-$HOME/.terminal-beauty-backups}"
stamp="$(date +%Y%m%d-%H%M%S)"
dest="$backup_root/$stamp"
mkdir -p "$dest"
manifest="$dest/manifest.txt"
: > "$manifest"

backup_one() {
  local src="$1"
  [ -e "$src" ] || return 0
  local base
  base="$(printf '%s' "$src" | sed "s|^$HOME|HOME|; s|/|_|g")"
  cp -R "$src" "$dest/$base"
  printf '%s\t%s\n' "$base" "$src" >> "$manifest"
}

backup_one "$HOME/.zshrc"
backup_one "$HOME/.config/starship.toml"
backup_one "$HOME/.config/fish"

if defaults read com.googlecode.iterm2 >/dev/null 2>&1; then
  defaults export com.googlecode.iterm2 "$dest/iterm2.plist"
  printf '%s\t%s\n' "iterm2.plist" "defaults:com.googlecode.iterm2" >> "$manifest"
fi

echo "$dest"
```

- [ ] **Step 4: Make it executable**

Run: `chmod +x scripts/backup.sh`

- [ ] **Step 5: Run test to verify it passes**

Run: `bats tests/backup.bats`
Expected: PASS — 3 tests.

- [ ] **Step 6: Commit**

```bash
git add scripts/backup.sh tests/backup.bats
git commit -m "feat: add config backup script"
```

---

## Task 4: rollback.sh — restore from backup

**Files:**
- Create: `scripts/rollback.sh`
- Test: `tests/rollback.bats`

- [ ] **Step 1: Write the failing test**

Create `tests/rollback.bats`:
```bash
load test_helper

setup() { setup_sandbox; }
teardown() { teardown_sandbox; }

@test "rollback.sh with no args lists available backups" {
  mkdir -p "$FAKE_HOME/.terminal-beauty-backups/20260101-120000"
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/rollback.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"20260101-120000"* ]]
}

@test "rollback.sh reports when there are no backups" {
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/rollback.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No backups"* ]]
}

@test "rollback.sh restores a file from a backup dir" {
  # Build a backup manually.
  bdir="$SANDBOX/backups/20260101-120000"
  mkdir -p "$bdir"
  echo "restored content" > "$bdir/HOME_.zshrc"
  printf '%s\t%s\n' "HOME_.zshrc" "$FAKE_HOME/.zshrc" > "$bdir/manifest.txt"

  echo "current content" > "$FAKE_HOME/.zshrc"
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/rollback.sh" "$bdir"
  [ "$status" -eq 0 ]
  [ "$(cat "$FAKE_HOME/.zshrc")" = "restored content" ]
}

@test "rollback.sh fails when the manifest is missing" {
  bdir="$SANDBOX/backups/empty"
  mkdir -p "$bdir"
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/rollback.sh" "$bdir"
  [ "$status" -ne 0 ]
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bats tests/rollback.bats`
Expected: FAIL — `rollback.sh` does not exist.

- [ ] **Step 3: Write rollback.sh**

Create `scripts/rollback.sh`:
```bash
#!/usr/bin/env bash
# Restores terminal config files from a backup directory.
# Usage:
#   rollback.sh              -> lists available backups under ~/.terminal-beauty-backups
#   rollback.sh <backup_dir> -> restores files recorded in that backup's manifest
set -euo pipefail

backup_root="$HOME/.terminal-beauty-backups"

if [ $# -eq 0 ]; then
  if [ -d "$backup_root" ] && [ -n "$(ls -A "$backup_root" 2>/dev/null)" ]; then
    echo "Available backups:"
    ls -1 "$backup_root"
  else
    echo "No backups found in $backup_root"
  fi
  exit 0
fi

backup_dir="$1"
manifest="$backup_dir/manifest.txt"
if [ ! -f "$manifest" ]; then
  echo "No manifest found in $backup_dir" >&2
  exit 1
fi

while IFS=$'\t' read -r base src; do
  [ -z "$base" ] && continue
  if [ "$src" = "defaults:com.googlecode.iterm2" ]; then
    defaults import com.googlecode.iterm2 "$backup_dir/$base"
  else
    rm -rf "$src"
    cp -R "$backup_dir/$base" "$src"
  fi
  echo "restored $src"
done < "$manifest"
```

- [ ] **Step 4: Make it executable**

Run: `chmod +x scripts/rollback.sh`

- [ ] **Step 5: Run test to verify it passes**

Run: `bats tests/rollback.bats`
Expected: PASS — 4 tests.

- [ ] **Step 6: Commit**

```bash
git add scripts/rollback.sh tests/rollback.bats
git commit -m "feat: add rollback script"
```

---

## Task 5: End-to-end script integration test

**Files:**
- Create: `tests/e2e.bats`

- [ ] **Step 1: Write the end-to-end test**

Create `tests/e2e.bats`:
```bash
load test_helper

setup() { setup_sandbox; }
teardown() { teardown_sandbox; }

@test "detect -> backup -> modify -> rollback restores original config" {
  # Original state.
  echo "ORIGINAL ZSHRC" > "$FAKE_HOME/.zshrc"

  # Detect (should not error).
  run env SHELL=/bin/zsh TERM_PROGRAM=iTerm.app HOME="$FAKE_HOME" \
    bash "$(scripts_dir)/detect.sh"
  [ "$status" -eq 0 ]

  # Backup.
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/backup.sh" "$SANDBOX/backups"
  [ "$status" -eq 0 ]
  backup_dir="$output"

  # Simulate "applying a theme" by overwriting the config.
  echo "THEMED ZSHRC" > "$FAKE_HOME/.zshrc"
  [ "$(cat "$FAKE_HOME/.zshrc")" = "THEMED ZSHRC" ]

  # Rollback.
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/rollback.sh" "$backup_dir"
  [ "$status" -eq 0 ]

  # Config is byte-for-byte back to original.
  [ "$(cat "$FAKE_HOME/.zshrc")" = "ORIGINAL ZSHRC" ]
}
```

- [ ] **Step 2: Run the test**

Run: `bats tests/e2e.bats`
Expected: PASS — 1 test.

- [ ] **Step 3: Run the whole suite**

Run: `bats tests/`
Expected: PASS — all 12 tests across 4 files.

- [ ] **Step 4: Commit**

```bash
git add tests/e2e.bats
git commit -m "test: add end-to-end backup/rollback integration test"
```

---

## Task 6: Theme format + Tokyo Night (complete worked example)

This task defines the exact format every theme directory follows and ships the first theme in full. Tasks 7-9 replicate this structure with different palettes.

**Files:**
- Create: `references/theme-format.md`
- Create: `themes/tokyo-night/theme.md`
- Create: `themes/tokyo-night/zsh.sh`
- Create: `themes/tokyo-night/starship.toml`
- Create: `themes/tokyo-night/iterm.itermcolors`
- Create: `themes/tokyo-night/fish.fish`

- [ ] **Step 1: Write the theme format reference**

Create `references/theme-format.md`:
```markdown
# Theme directory format

Every theme is a directory under `themes/<name>/` with exactly five files.

## theme.md
Human-readable metadata. Sections:
- `# <Display Name>` heading
- One-paragraph style description (mood, who it suits)
- A `## Palette` section listing 18 hex colors as a markdown table:
  bg, fg, then ansi 0-15 (black, red, green, yellow, blue, magenta, cyan,
  white, bright variants in the same order).

## zsh.sh
A snippet sourced from `.zshrc`. Sets `LSCOLORS`/`LS_COLORS` and, if the
`zsh-syntax-highlighting` plugin is present, palette-matched highlight
colors. Sources Starship if installed. Must be idempotent.

## starship.toml
A complete Starship configuration using the theme palette for prompt
module colors. Drop-in replacement for `~/.config/starship.toml`.

## iterm.itermcolors
An iTerm2 color preset (plist XML). Contains `Ansi 0 Color` .. `Ansi 15
Color`, plus `Background Color`, `Foreground Color`, `Cursor Color`,
`Cursor Text Color`, `Selection Color`, `Selected Text Color`, `Bold
Color`, `Link Color`. Each is a dict of `Red/Green/Blue Component` floats.

### Hex to plist float conversion
For hex `#RRGGBB`: each component float = decimal(channel) / 255.
Example: `#1a1b26` -> R=26/255=0.10196, G=27/255=0.10588, B=38/255=0.14902.
Use at least 5 decimal places.

## fish.fish
A snippet for `~/.config/fish/conf.d/`. Sets fish color variables
(`fish_color_*`) from the palette and sources Starship if installed.
```

- [ ] **Step 2: Write Tokyo Night theme.md**

Create `themes/tokyo-night/theme.md`:
```markdown
# Tokyo Night

A calm, dark theme inspired by the neon-lit night of Tokyo. Deep navy
background with soft pastel accents — low eye strain, good for long
sessions. Suits people who want dark-but-not-harsh.

## Palette

| Role          | Hex     |
|---------------|---------|
| bg            | #1a1b26 |
| fg            | #c0caf5 |
| black         | #15161e |
| red           | #f7768e |
| green         | #9ece6a |
| yellow        | #e0af68 |
| blue          | #7aa2f7 |
| magenta       | #bb9af7 |
| cyan          | #7dcfff |
| white         | #a9b1d6 |
| bright black  | #414868 |
| bright red    | #f7768e |
| bright green  | #9ece6a |
| bright yellow | #e0af68 |
| bright blue   | #7aa2f7 |
| bright magenta| #bb9af7 |
| bright cyan   | #7dcfff |
| bright white  | #c0caf5 |
```

- [ ] **Step 3: Write Tokyo Night zsh.sh**

Create `themes/tokyo-night/zsh.sh`:
```bash
# terminal-beauty: Tokyo Night (zsh)
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS="di=38;2;122;162;247:ln=38;2;125;207;255:ex=38;2;158;206;106"

if typeset -f _zsh_highlight >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_STYLES[command]='fg=#9ece6a'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7dcfff'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e'
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

- [ ] **Step 4: Write Tokyo Night starship.toml**

Create `themes/tokyo-night/starship.toml`:
```toml
# terminal-beauty: Tokyo Night
add_newline = true

format = """
[](#7aa2f7)\
$directory\
[](fg:#7aa2f7 bg:#bb9af7)\
$git_branch\
$git_status\
[](fg:#bb9af7 bg:#414868)\
$cmd_duration\
[ ](fg:#414868)\
$character"""

[directory]
style = "fg:#1a1b26 bg:#7aa2f7"
format = "[ $path ]($style)"
truncation_length = 3

[git_branch]
symbol = ""
style = "fg:#1a1b26 bg:#bb9af7"
format = "[ $symbol $branch ]($style)"

[git_status]
style = "fg:#1a1b26 bg:#bb9af7"
format = "[$all_status$ahead_behind ]($style)"

[cmd_duration]
style = "fg:#c0caf5 bg:#414868"
format = "[  $duration ]($style)"

[character]
success_symbol = "[❯](bold #9ece6a)"
error_symbol = "[❯](bold #f7768e)"
```

- [ ] **Step 5: Write Tokyo Night iterm.itermcolors**

Create `themes/tokyo-night/iterm.itermcolors`. Use this exact structure;
each color's float components are `hex_channel / 255`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Ansi 0 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.08235</real><key>Green Component</key><real>0.08627</real><key>Blue Component</key><real>0.11765</real></dict>
	<key>Ansi 1 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.96863</real><key>Green Component</key><real>0.46275</real><key>Blue Component</key><real>0.55686</real></dict>
	<key>Ansi 2 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.61961</real><key>Green Component</key><real>0.80784</real><key>Blue Component</key><real>0.41569</real></dict>
	<key>Ansi 3 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.87843</real><key>Green Component</key><real>0.68627</real><key>Blue Component</key><real>0.40784</real></dict>
	<key>Ansi 4 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.47843</real><key>Green Component</key><real>0.63529</real><key>Blue Component</key><real>0.96863</real></dict>
	<key>Ansi 5 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.73333</real><key>Green Component</key><real>0.60392</real><key>Blue Component</key><real>0.96863</real></dict>
	<key>Ansi 6 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.49020</real><key>Green Component</key><real>0.81176</real><key>Blue Component</key><real>1.00000</real></dict>
	<key>Ansi 7 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.66275</real><key>Green Component</key><real>0.69412</real><key>Blue Component</key><real>0.83922</real></dict>
	<key>Ansi 8 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.25490</real><key>Green Component</key><real>0.28235</real><key>Blue Component</key><real>0.40784</real></dict>
	<key>Ansi 9 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.96863</real><key>Green Component</key><real>0.46275</real><key>Blue Component</key><real>0.55686</real></dict>
	<key>Ansi 10 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.61961</real><key>Green Component</key><real>0.80784</real><key>Blue Component</key><real>0.41569</real></dict>
	<key>Ansi 11 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.87843</real><key>Green Component</key><real>0.68627</real><key>Blue Component</key><real>0.40784</real></dict>
	<key>Ansi 12 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.47843</real><key>Green Component</key><real>0.63529</real><key>Blue Component</key><real>0.96863</real></dict>
	<key>Ansi 13 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.73333</real><key>Green Component</key><real>0.60392</real><key>Blue Component</key><real>0.96863</real></dict>
	<key>Ansi 14 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.49020</real><key>Green Component</key><real>0.81176</real><key>Blue Component</key><real>1.00000</real></dict>
	<key>Ansi 15 Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.75294</real><key>Green Component</key><real>0.79216</real><key>Blue Component</key><real>0.96078</real></dict>
	<key>Background Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.10196</real><key>Green Component</key><real>0.10588</real><key>Blue Component</key><real>0.14902</real></dict>
	<key>Foreground Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.75294</real><key>Green Component</key><real>0.79216</real><key>Blue Component</key><real>0.96078</real></dict>
	<key>Cursor Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.75294</real><key>Green Component</key><real>0.79216</real><key>Blue Component</key><real>0.96078</real></dict>
	<key>Cursor Text Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.10196</real><key>Green Component</key><real>0.10588</real><key>Blue Component</key><real>0.14902</real></dict>
	<key>Selection Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.25490</real><key>Green Component</key><real>0.28235</real><key>Blue Component</key><real>0.40784</real></dict>
	<key>Selected Text Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.75294</real><key>Green Component</key><real>0.79216</real><key>Blue Component</key><real>0.96078</real></dict>
	<key>Bold Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.75294</real><key>Green Component</key><real>0.79216</real><key>Blue Component</key><real>0.96078</real></dict>
	<key>Link Color</key>
	<dict><key>Color Space</key><string>sRGB</string><key>Red Component</key><real>0.47843</real><key>Green Component</key><real>0.63529</real><key>Blue Component</key><real>0.96863</real></dict>
</dict>
</plist>
```

- [ ] **Step 6: Write Tokyo Night fish.fish**

Create `themes/tokyo-night/fish.fish`:
```fish
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
```

- [ ] **Step 7: Validate the files**

Run:
```bash
plutil -lint themes/tokyo-night/iterm.itermcolors
bash -n themes/tokyo-night/zsh.sh
```
Expected: `OK` from plutil; no output (no syntax error) from `bash -n`.

- [ ] **Step 8: Commit**

```bash
git add references/theme-format.md themes/tokyo-night
git commit -m "feat: add theme format spec and Tokyo Night theme"
```

---

## Task 7: Themes batch A — Dracula, Nord, Catppuccin

For each theme below, create a directory `themes/<name>/` with all five
files (`theme.md`, `zsh.sh`, `starship.toml`, `iterm.itermcolors`,
`fish.fish`), following the exact structure of `themes/tokyo-night/`
defined in Task 6. Only the palette and the display name/description
change. For `iterm.itermcolors`, convert each hex to float components
with `channel / 255` as documented in `references/theme-format.md`.

**Files (create all):**
- `themes/dracula/{theme.md,zsh.sh,starship.toml,iterm.itermcolors,fish.fish}`
- `themes/nord/{theme.md,zsh.sh,starship.toml,iterm.itermcolors,fish.fish}`
- `themes/catppuccin/{theme.md,zsh.sh,starship.toml,iterm.itermcolors,fish.fish}`

- [ ] **Step 1: Create the Dracula theme**

Display name: `Dracula`. Description: "A vivid dark theme with high-saturation
accents on a muted purple-grey background. Bold and playful — suits people who
want their terminal to pop."

Palette:
| Role | Hex | Role | Hex |
|------|-----|------|-----|
| bg | #282a36 | fg | #f8f8f2 |
| black | #21222c | bright black | #6272a4 |
| red | #ff5555 | bright red | #ff6e6e |
| green | #50fa7b | bright green | #69ff94 |
| yellow | #f1fa8c | bright yellow | #ffffa5 |
| blue | #bd93f9 | bright blue | #d6acff |
| magenta | #ff79c6 | bright magenta | #ff92df |
| cyan | #8be9fd | bright cyan | #a4ffff |
| white | #f8f8f2 | bright white | #ffffff |

In `starship.toml` use: directory bg = blue, git bg = magenta, duration bg =
bright black, success char = green, error char = red. In `zsh.sh` /
`fish.fish` map command=blue, keyword=magenta, quote=green, error=red,
comment=bright black, normal=fg.

- [ ] **Step 2: Create the Nord theme**

Display name: `Nord`. Description: "An arctic, north-bluish palette. Cool,
desaturated, and quiet — suits people who want a calm, low-contrast workspace."

Palette:
| Role | Hex | Role | Hex |
|------|-----|------|-----|
| bg | #2e3440 | fg | #d8dee9 |
| black | #3b4252 | bright black | #4c566a |
| red | #bf616a | bright red | #bf616a |
| green | #a3be8c | bright green | #a3be8c |
| yellow | #ebcb8b | bright yellow | #ebcb8b |
| blue | #81a1c1 | bright blue | #81a1c1 |
| magenta | #b48ead | bright magenta | #b48ead |
| cyan | #88c0d0 | bright cyan | #8fbcbb |
| white | #e5e9f0 | bright white | #eceff4 |

Same module mapping rule as Step 1 (directory bg = blue, git bg = magenta,
duration bg = bright black, success = green, error = red).

- [ ] **Step 3: Create the Catppuccin theme**

Display name: `Catppuccin Mocha`. Description: "A soft, pastel dark theme.
Gentle contrast and warm accents — suits people who want cozy and easy on
the eyes."

Palette:
| Role | Hex | Role | Hex |
|------|-----|------|-----|
| bg | #1e1e2e | fg | #cdd6f4 |
| black | #45475a | bright black | #585b70 |
| red | #f38ba8 | bright red | #f38ba8 |
| green | #a6e3a1 | bright green | #a6e3a1 |
| yellow | #f9e2af | bright yellow | #f9e2af |
| blue | #89b4fa | bright blue | #89b4fa |
| magenta | #f5c2e7 | bright magenta | #f5c2e7 |
| cyan | #94e2d5 | bright cyan | #94e2d5 |
| white | #bac2de | bright white | #a6adc8 |

Same module mapping rule as Step 1.

- [ ] **Step 4: Validate**

Run:
```bash
for t in dracula nord catppuccin; do
  plutil -lint "themes/$t/iterm.itermcolors"
  bash -n "themes/$t/zsh.sh"
done
```
Expected: `OK` for each plist; no output from `bash -n`.

- [ ] **Step 5: Commit**

```bash
git add themes/dracula themes/nord themes/catppuccin
git commit -m "feat: add Dracula, Nord, and Catppuccin themes"
```

---

## Task 8: Themes batch B — Gruvbox, Rosé Pine

Same procedure as Task 7: each theme is a directory with the five files,
structured exactly like `themes/tokyo-night/`.

**Files (create all):**
- `themes/gruvbox/{theme.md,zsh.sh,starship.toml,iterm.itermcolors,fish.fish}`
- `themes/rose-pine/{theme.md,zsh.sh,starship.toml,iterm.itermcolors,fish.fish}`

- [ ] **Step 1: Create the Gruvbox theme**

Display name: `Gruvbox Dark`. Description: "A retro, warm theme with earthy
browns and muted primaries. Comfortable and nostalgic — suits people who like
a vintage, low-blue-light feel."

Palette:
| Role | Hex | Role | Hex |
|------|-----|------|-----|
| bg | #282828 | fg | #ebdbb2 |
| black | #282828 | bright black | #928374 |
| red | #cc241d | bright red | #fb4934 |
| green | #98971a | bright green | #b8bb26 |
| yellow | #d79921 | bright yellow | #fabd2f |
| blue | #458588 | bright blue | #83a598 |
| magenta | #b16286 | bright magenta | #d3869b |
| cyan | #689d6a | bright cyan | #8ec07c |
| white | #a89984 | bright white | #ebdbb2 |

Module mapping: directory bg = blue, git bg = magenta, duration bg = bright
black, success = green, error = bright red.

- [ ] **Step 2: Create the Rosé Pine theme**

Display name: `Rosé Pine`. Description: "A muted, romantic theme — soft rose
and pine on a deep plum background. Elegant and understated."

Palette:
| Role | Hex | Role | Hex |
|------|-----|------|-----|
| bg | #191724 | fg | #e0def4 |
| black | #26233a | bright black | #6e6a86 |
| red | #eb6f92 | bright red | #eb6f92 |
| green | #31748f | bright green | #31748f |
| yellow | #f6c177 | bright yellow | #f6c177 |
| blue | #9ccfd8 | bright blue | #9ccfd8 |
| magenta | #c4a7e7 | bright magenta | #c4a7e7 |
| cyan | #ebbcba | bright cyan | #ebbcba |
| white | #e0def4 | bright white | #e0def4 |

Module mapping: directory bg = magenta (#c4a7e7), git bg = red (#eb6f92),
duration bg = bright black, success = blue (#9ccfd8), error = red (#eb6f92).
(Rosé Pine has no strong green, so blue stands in for the success accent.)

- [ ] **Step 3: Validate**

Run:
```bash
for t in gruvbox rose-pine; do
  plutil -lint "themes/$t/iterm.itermcolors"
  bash -n "themes/$t/zsh.sh"
done
```
Expected: `OK` for each plist; no output from `bash -n`.

- [ ] **Step 4: Commit**

```bash
git add themes/gruvbox themes/rose-pine
git commit -m "feat: add Gruvbox and Rosé Pine themes"
```

---

## Task 9: Themes batch C — Everforest, Solarized Dark

Same procedure as Tasks 7-8.

**Files (create all):**
- `themes/everforest/{theme.md,zsh.sh,starship.toml,iterm.itermcolors,fish.fish}`
- `themes/solarized-dark/{theme.md,zsh.sh,starship.toml,iterm.itermcolors,fish.fish}`

- [ ] **Step 1: Create the Everforest theme**

Display name: `Everforest`. Description: "A green-based, low-contrast forest
theme. Warm and soft — designed to be gentle on the eyes for long sessions."

Palette:
| Role | Hex | Role | Hex |
|------|-----|------|-----|
| bg | #2d353b | fg | #d3c6aa |
| black | #475258 | bright black | #56635f |
| red | #e67e80 | bright red | #e67e80 |
| green | #a7c080 | bright green | #a7c080 |
| yellow | #dbbc7f | bright yellow | #dbbc7f |
| blue | #7fbbb3 | bright blue | #7fbbb3 |
| magenta | #d699b6 | bright magenta | #d699b6 |
| cyan | #83c092 | bright cyan | #83c092 |
| white | #d3c6aa | bright white | #d3c6aa |

Module mapping: directory bg = blue, git bg = magenta, duration bg = bright
black, success = green, error = red.

- [ ] **Step 2: Create the Solarized Dark theme**

Display name: `Solarized Dark`. Description: "The classic precision palette —
low-saturation accents tuned for consistent contrast on a teal-dark
background. Suits people who want a proven, balanced scheme."

Palette:
| Role | Hex | Role | Hex |
|------|-----|------|-----|
| bg | #002b36 | fg | #839496 |
| black | #073642 | bright black | #002b36 |
| red | #dc322f | bright red | #cb4b16 |
| green | #859900 | bright green | #586e75 |
| yellow | #b58900 | bright yellow | #657b83 |
| blue | #268bd2 | bright blue | #839496 |
| magenta | #d33682 | bright magenta | #6c71c4 |
| cyan | #2aa198 | bright cyan | #93a1a1 |
| white | #eee8d5 | bright white | #fdf6e3 |

Module mapping: directory bg = blue, git bg = magenta, duration bg = black
(#073642), success = green, error = red.

- [ ] **Step 3: Validate**

Run:
```bash
for t in everforest solarized-dark; do
  plutil -lint "themes/$t/iterm.itermcolors"
  bash -n "themes/$t/zsh.sh"
done
```
Expected: `OK` for each plist; no output from `bash -n`.

- [ ] **Step 4: Commit**

```bash
git add themes/everforest themes/solarized-dark
git commit -m "feat: add Everforest and Solarized Dark themes"
```

---

## Task 10: Custom theme generation guide

**Files:**
- Create: `references/custom-theme-guide.md`

- [ ] **Step 1: Write the custom theme guide**

Create `references/custom-theme-guide.md`:
```markdown
# Generating a custom theme

Use this when the user wants a look not covered by the curated library
(e.g. "warm retro", "high-contrast neon", "matches my brand colors").

## Steps

1. **Clarify the brief.** Ask for: light or dark, overall mood, any
   must-have colors. Keep it to one or two questions.

2. **Design an 18-colour palette.** Produce hex values for: bg, fg, and
   ansi 0-15 (black, red, green, yellow, blue, magenta, cyan, white, then
   the eight bright variants).
   - Background and foreground must meet at least a 7:1 contrast ratio.
   - The six accent colours (red/green/yellow/blue/magenta/cyan) must each
     be clearly distinguishable from one another and readable on bg.
   - Bright variants are lighter/more saturated versions of the base.

3. **Create the theme directory.** Write the five files into
   `themes/_custom/<slug>/`, following `references/theme-format.md`
   exactly — the same structure as `themes/tokyo-night/`.

4. **Apply it** through the normal workflow in SKILL.md (backup first).

## Notes
- `themes/_custom/` is git-ignored and may be overwritten freely.
- If the user later likes a custom theme enough to keep, they can move
  the directory out of `_custom/` and rename it.
```

- [ ] **Step 2: Ignore the custom theme scratch directory**

Append to `.gitignore`:
```
themes/_custom/
```

- [ ] **Step 3: Commit**

```bash
git add references/custom-theme-guide.md .gitignore
git commit -m "feat: add custom theme generation guide"
```

---

## Task 11: SKILL.md — the workflow

**Files:**
- Create: `SKILL.md`

- [ ] **Step 1: Write SKILL.md**

Create `SKILL.md`:
```markdown
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
```

- [ ] **Step 2: Verify the frontmatter parses**

Run:
```bash
head -5 SKILL.md
```
Expected: valid YAML frontmatter with `name:` and `description:`.

- [ ] **Step 3: Commit**

```bash
git add SKILL.md
git commit -m "feat: add terminal-beauty SKILL.md workflow"
```

---

## Task 12: Install the skill and smoke-test it

**Files:**
- None created — installs the skill for real use.

- [ ] **Step 1: Install the skill into Claude Code**

Run:
```bash
mkdir -p ~/.claude/skills
ln -sfn "$(pwd)" ~/.claude/skills/terminal-beauty
```
Expected: `~/.claude/skills/terminal-beauty` symlinks to the repo.

- [ ] **Step 2: Run the full test suite once more**

Run: `bats tests/`
Expected: PASS — all 13 tests.

- [ ] **Step 3: Smoke-test detection on the real machine**

Run: `bash scripts/detect.sh`
Expected: five `key=value` lines describing this machine's actual terminal
environment.

- [ ] **Step 4: Manual skill check**

In a new Claude Code session, type "美化我的 terminal" and confirm the
`terminal-beauty` skill is offered/triggered. Walk through detect → present
themes → (decline to apply) to confirm the workflow reads correctly. This
step is manual and cannot be automated here.

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "chore: terminal-beauty skill complete" --allow-empty
```
```
```

---

## Self-Review

**Spec coverage:**
- 4 supported tools (zsh/Starship/iTerm2/fish) → each theme ships all four config files (Tasks 6-9); SKILL.md applies each (Task 11). ✓
- Hybrid flow (detect → present → apply → install commands) → SKILL.md steps 1-6 (Task 11). ✓
- Preview by applying to the real terminal + rollback → backup.sh/rollback.sh (Tasks 3-4), SKILL.md steps 4-7. ✓
- Curated library of 8 themes → Tasks 6-9. ✓
- Custom generation → references/custom-theme-guide.md (Task 10), SKILL.md step 3. ✓
- Backup never deleted, backup before every apply → SKILL.md safety rules, backup.sh timestamped dirs. ✓
- Missing-tool handling (consent before install) → SKILL.md step 5. ✓
- Unsupported terminal handling → SKILL.md step 5. ✓
- New/empty environment → backup.sh `backup_one` skips non-existent files (Task 3); SKILL.md zsh apply appends to `.zshrc` (created if absent). ✓
- iTerm2 special handling (generate file + guided import / dynamic profiles) → SKILL.md step 5. ✓
- Testing strategy (unit + e2e) → Tasks 2-5; trigger accuracy → Task 12 step 4. ✓

**Placeholder scan:** Theme tasks 7-9 supply complete palettes + a fully specified format (Task 6 + theme-format.md), not placeholders — the file content is deterministic given palette + template. No TBD/TODO remain.

**Type consistency:** `backup.sh` writes tab-separated `base<TAB>src` lines to `manifest.txt`; `rollback.sh` reads with `IFS=$'\t'` — consistent. iTerm2 sentinel `defaults:com.googlecode.iterm2` written by backup.sh and matched by rollback.sh — consistent. Script paths (`scripts/detect.sh` etc.) consistent across tasks and SKILL.md.
