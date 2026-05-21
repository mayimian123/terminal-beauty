load test_helper

setup() { setup_sandbox; }
teardown() { teardown_sandbox; }

@test "install.sh lists themes without a theme argument" {
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/install.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"tokyo-night"* ]]
}

@test "install.sh rejects unknown themes" {
  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/install.sh" missing-theme
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown theme"* ]]
}

@test "install.sh backs up and applies a selected theme" {
  echo "ORIGINAL ZSHRC" > "$FAKE_HOME/.zshrc"

  run env HOME="$FAKE_HOME" TERM_PROGRAM=Apple_Terminal \
    bash "$(scripts_dir)/install.sh" tokyo-night
  [ "$status" -eq 0 ]

  [ -d "$FAKE_HOME/.terminal-beauty/themes/tokyo-night" ]
  [ -f "$FAKE_HOME/.config/starship.toml" ]
  grep -q 'terminal-beauty: tokyo-night' "$FAKE_HOME/.zshrc"
  [ -n "$(find "$FAKE_HOME/.terminal-beauty-backups" -name manifest.txt -print -quit)" ]
}

@test "install.sh replaces the previous terminal-beauty zsh source" {
  echo "ORIGINAL ZSHRC" > "$FAKE_HOME/.zshrc"

  run env HOME="$FAKE_HOME" TERM_PROGRAM=Apple_Terminal \
    bash "$(scripts_dir)/install.sh" tokyo-night
  [ "$status" -eq 0 ]

  run env HOME="$FAKE_HOME" TERM_PROGRAM=Apple_Terminal \
    bash "$(scripts_dir)/install.sh" nord
  [ "$status" -eq 0 ]

  grep -q 'terminal-beauty: nord' "$FAKE_HOME/.zshrc"
  ! grep -q 'terminal-beauty: tokyo-night' "$FAKE_HOME/.zshrc"
  [ "$(grep -c '.terminal-beauty/themes/.*/zsh.sh' "$FAKE_HOME/.zshrc")" -eq 1 ]
}

@test "install.sh removes legacy skill zsh sources" {
  {
    echo 'source /Users/test/.claude/skills/terminal-beauty/themes/rose-pine/zsh.sh'
    echo 'source "/Users/test/.codex/skills/terminal-beauty/themes/nord/zsh.sh"'
    echo 'source "/Users/test/Desktop/terminal-beauty/themes/dracula/zsh.sh"'
  } > "$FAKE_HOME/.zshrc"

  run env HOME="$FAKE_HOME" TERM_PROGRAM=Apple_Terminal \
    bash "$(scripts_dir)/install.sh" catppuccin
  [ "$status" -eq 0 ]

  ! grep -q '.claude/skills/terminal-beauty' "$FAKE_HOME/.zshrc"
  ! grep -q '.codex/skills/terminal-beauty' "$FAKE_HOME/.zshrc"
  ! grep -q 'Desktop/terminal-beauty/themes' "$FAKE_HOME/.zshrc"
  grep -q '.terminal-beauty/themes/catppuccin/zsh.sh' "$FAKE_HOME/.zshrc"
}
