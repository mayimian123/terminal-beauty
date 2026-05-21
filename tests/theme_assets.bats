load test_helper

@test "each curated theme includes an Apple Terminal profile" {
  themes_root="$BATS_TEST_DIRNAME/../themes"

  for theme_dir in "$themes_root"/*; do
    [ -d "$theme_dir" ] || continue
    [ "$(basename "$theme_dir")" != "_custom" ] || continue

    profile="$theme_dir/terminal.terminal"
    [ -f "$profile" ]

    plutil -lint "$profile" >/dev/null
    plutil -p "$profile" | grep -q "ANSIBlackColor"
    plutil -p "$profile" | grep -q "BackgroundColor"
  done
}
