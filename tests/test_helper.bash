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
