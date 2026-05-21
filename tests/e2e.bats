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
