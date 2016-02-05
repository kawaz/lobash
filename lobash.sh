#!/bin/bash
: "1.0.0"; eval "[[ -n \"\$LOBASH_VERSION\" ]] && lo.version_ge \"\$LOBASH_VERSION\" $_ && return; LOBASH_VERSION=$_"

lo.version_ge() {
  if [[ $# == 1 ]]; then
    local v1=(${BASH_VERSINFO[*]//[^0-9]/ })
  else
    local v1=(${1//[^0-9]/ })
    shift
  fi
  local v2=(${1//[^0-9]/ })
  [[ ${#v1[@]} == 0 ]] && return 1
  local idx
  for idx in "${!v2[@]}"; do
    if [[ -z ${v1[$idx]} ]]; then
      [[ -z ${v2[$idx]##0} ]] && continue
    else
      [[ ${v1[$idx]##0} -gt "${v2[$idx]##0}" ]] && return 0
      [[ ${v1[$idx]##0} -eq "${v2[$idx]##0}" ]] && continue
    fi
    return 1
  done
}

lo.echo() {
  printf '%s\n' "$*"
}

lo.echo_each() {
  for _ in "$@"; do
    lo.echo "$_"
  done
}

lo.die() {
  lo.echo_each "$@" >&2
  exit 1
}

lo.is_executed() {
  [[ ${BASH_SOURCE[1]} == "$0" ]]
}

lo.is_sourced() {
  [[ ${BASH_SOURCE[1]} != "$0" ]]
}

lo.die_source_only() {
  # shellcheck disable=SC2155
  lo.is_sourced || lo.die "Don't execute. You must use it like the next." ". $(printf %q "$0")"
}
lo.die_source_only
