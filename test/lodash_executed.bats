#!/usr/bin/env bats
lobash_path="$BATS_TEST_DIRNAME/../lobash.sh"

setup() {
  old_PATH=$PATH
  tmp_PATH="${BATS_TMPDIR}/${BATS_TEST_NAME}/${BATS_TEST_NUMBER}"
  mkdir -p "$tmp_PATH"
  cp "$lobash_path" "$tmp_PATH/lobash.sh"
  chmod 755 "$tmp_PATH/lobash.sh"
  export PATH="$tmp_PATH:$PATH"
}

teardown() {
  export PATH=$old_PATH
  rm -rf "${tmp_PATH?}"
}

# shellcheck disable=SC2155
@test "If execute lobash.sh, it must be failed." {
  # execute absolute path
  ! "$tmp_PATH/lobash.sh"
  # execute in $PATH
  ! lobash.sh
  # status code is 1
  lobash.sh || [[ $? == 1 ]]

  local out=$(lobash.sh)
  local err=$(lobash.sh 2>&1)
  [[ -z $out ]]
  [[ $err == "Don't execute"* ]]
}
