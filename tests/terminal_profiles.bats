load test_helper

setup() { setup_sandbox; }
teardown() { teardown_sandbox; }

@test "import_terminal_profiles.py imports all curated profiles and sets default" {
  prefs="$SANDBOX/com.apple.Terminal.plist"
  printf '%s' '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>Window Settings</key><dict></dict></dict></plist>' > "$prefs"

  run python3 "$BATS_TEST_DIRNAME/../scripts/import_terminal_profiles.py" \
    --prefs-plist "$prefs" \
    --set-default catppuccin
  [ "$status" -eq 0 ]
  [[ "$output" == *"catppuccin (default)"* ]]

  [ "$(plutil -extract 'Default Window Settings' raw "$prefs")" = "catppuccin" ]
  [ "$(plutil -extract 'Startup Window Settings' raw "$prefs")" = "catppuccin" ]
  plutil -p "$prefs" | grep -q '"tokyo-night"'
  plutil -p "$prefs" | grep -q '"catppuccin"'
}
