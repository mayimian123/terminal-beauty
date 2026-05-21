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

@test "backup.sh creates a unique directory when called twice in one second" {
  echo "original zshrc" > "$FAKE_HOME/.zshrc"

  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/backup.sh" "$SANDBOX/backups"
  [ "$status" -eq 0 ]
  first="$output"

  run env HOME="$FAKE_HOME" bash "$(scripts_dir)/backup.sh" "$SANDBOX/backups"
  [ "$status" -eq 0 ]
  second="$output"

  [ "$first" != "$second" ]
  [ -d "$first" ]
  [ -d "$second" ]
}
