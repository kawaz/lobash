#!/usr/bin/env bats
lobash_path="$BATS_TEST_DIRNAME/../lobash.sh"
lobash_path_q=$(printf %q "$lobash_path")

setup() {
  local tmp_PATH="$BATS_TMPDIR/${BATS_TEST_NAME}/${BATS_TEST_NUMBER}/bin"
  mkdir -p "$tmp_PATH"
  cp "$lobash_path" "$tmp_PATH/lobash.sh"
  chmod 755 "$tmp_PATH/lobash.sh"
  export PATH="$tmp_PATH:$PATH"
}

@test "If execute lobash.sh, it must be failed." {
  # execute absolute path
  ! $tmp_PATH/lobash.sh
  # execute in $PATH
  ! lobash.sh
  # status code is 1
  run "lobash.sh"
  [[ $status == 1 ]]

  local out=$(lobash.sh)
  local err=$(lobash.sh 2>&1)
  [[ -z $out ]]
  [[ $err == "Don't execute"* ]]
}
