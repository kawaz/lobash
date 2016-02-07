#!/usr/bin/env bats

# shellcheck disable=SC2034
setup() {
  declare -p BATS_TEST_DIRNAME >>/tmp/test 2>&1
  lobash_path="$BATS_TEST_DIRNAME/../lobash.sh"
  lobash_path_q=$(printf %q "$lobash_path")
  # shellcheck source=../lobash.sh
  . "$lobash_path"
}

@test "version_ge <no_args> is false." {
  ! lo.version_ge
}

@test "version_ge <one_arg>, it compare to \$BASH_VERSINFO." {
  # 1 arg meens $BASH_VERSINFO vs $1
  lo.version_ge 1
  lo.version_ge 1.0
  lo.version_ge "${BASH_VERSINFO[0]}"
  lo.version_ge "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
  lo.version_ge "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"
  lo.version_ge "${BASH_VERSINFO[0]}.0"
  lo.version_ge "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.0"
  lo.version_ge "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}.0"
  ! lo.version_ge 99999
  ! lo.version_ge "${BASH_VERSINFO[0]}.99999"
  ! lo.version_ge "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.99999"
  ! lo.version_ge "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}.99999"
  ! lo.version_ge $((BASH_VERSINFO[0]+1))
  ! lo.version_ge $((BASH_VERSINFO[0]+1)).$((BASH_VERSINFO[1]+1))
  ! lo.version_ge $((BASH_VERSINFO[0]+1)).$((BASH_VERSINFO[1]+1)).$((BASH_VERSINFO[2]+1))
}

@test "version_ge <valid> <null> is true." {
  lo.version_ge 1 ""
}

@test "version_ge <null> <any> is false." {
  ! lo.version_ge "" 1
  ! lo.version_ge "" ""
}

@test "version_ge ignore .0 trail version" {
  lo.version_ge 1 1.0
  lo.version_ge 1.0 1
  lo.version_ge 1 1.0.0
  lo.version_ge 1.0.0 1
  lo.version_ge 1.0 1.0.0
  lo.version_ge 1.0.0 1.0
  lo.version_ge 1.2 1.2.0
  lo.version_ge 1.2.0 1.2
}

@test "version_ge <same_value> <same_value> is true" {
  lo.version_ge 0 0
  lo.version_ge 1 1
  lo.version_ge 0.0 0.0
  lo.version_ge 1.2 1.2
  lo.version_ge 1.2.3 1.2.3
}

@test "version_ge <big> <small> is true, version_ge <small> <big> is false." {
  swaptest_version_ge 2 1
  swaptest_version_ge 2 1.0
  swaptest_version_ge 2 1.1
  swaptest_version_ge 2 1.999
  swaptest_version_ge 2.0 1.999
  swaptest_version_ge 2.0.0 1.999
  swaptest_version_ge 10.0 2.0
}

@test "version_ge trim zero padding. dont treat it as octal number." {
  swaptest_version_ge 02 01
  swaptest_version_ge 010 7
  swaptest_version_ge 010 8
  swaptest_version_ge 010 9
  lo.version_ge 010 10
  swaptest_version_ge 11 010
}

@test "version_ge <contain_non_numbe_versions..>" {
  # FIXME:
  skip
}

swaptest_version_ge() {
  lo.version_ge "$1" "$2" || return $?
  ! lo.version_ge "$2" "$1"
}
