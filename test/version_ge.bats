#!/usr/bin/env bats
lobash_path="$BATS_TEST_DIRNAME/../lobash.sh"
# shellcheck source=../lobash.sh
. "$lobash_path"

@test "version_ge" {
  # 0 args
  ! lo.version_ge
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
  # null value
  lo.version_ge 1 ""
  ! lo.version_ge "" 1
  ! lo.version_ge "" ""
  # 2 arg, test each swap
  local vv=(
  # ignore .0 trail
  1 1.0
  1 1.0.0
  1.0 1.0.0
  # equals
  0 0
  1 1
  0.0 0.0
  1.2 1.2
  1.2.3 1.2.3
  # grater than
  2 1
  2 1.0
  2 1.1
  2 1.999
  2.0 1.999
  2.0.0 1.999
  10.0 2.0
  # 0 padding (similer to the octal number)
  02 01
  010 7
  010 8
  010 9
  010 10
  11 010
  )
  local i j=${#vv[@]}
  for(( i=0; i < j; i+=2 )); do
    lo.version_ge "${vv[$i]}" "${vv[$i+1]}"
    ! lo.version_ge "${vv[$i+1]}" "${vv[$i]}"
  done
}

@test "version_ge <not_number>" {
  # FIXME:
  skip
}
