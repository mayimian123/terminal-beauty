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
