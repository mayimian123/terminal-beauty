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
