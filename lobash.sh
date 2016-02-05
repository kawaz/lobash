#!/bin/bash
v="1.0.0" \
  eval "[[ -n '$LOBASH_VERSION' ]] && lo.version_ge $LOBASH_VERSION \$v && return; LOBASH_VERSION=\$v"

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

lo.caniuse_hash() {
  lo.func_redirect lo.caniuse_associative_array "$@"
}

lo.caniuse_associative_array() {
  lo.version_ge 4
}

lo.caniuse_declare_g() {
  lo.version_ge 4.2
}

lo.caniuse_declare_n() {
  lo.version_ge 4.3
}

lo.caniuse_regexp() {
  lo.func_redirect lo.caniuse_regular_expressions "$@"
}

lo.caniuse_regular_expressions() {
  # 3.1未満でも使えるが右辺のクオートに関する仕様が違うので使わないべき
  lo.version_ge 3.1
}


# shellcheck disable=SC2155
lo.var_parse() {
  lo.validate_var_identifier "$@" || return 1
  local t=$(declare -p "$1" 2>/dev/null)
  [[ -z $t ]] && return 1
  t=${t#* }
  eval "declare -a $2='(${t%% *} ${t#*=})'"
}

lo.validate_var_identifier() {
  [[ $# != 0 ]] && for _ in "$@"; do [[ $_ == [a-zA-Z_]* && $_ != *[^a-zA-Z0-9_]* ]] || return 1; done
}

lo.var_defined() {
  declare -p -- "$@" >/dev/null 2>&1
}

lo.func_defined() {
  declare -F -- "$@" >/dev/null 2>&1
}

lo.func_deprecated() {
  printf '%s\n' "\`${FUNCNAME[1]}\` is deprecated.${1:+ Redirecting to \`$1\`.}" >&2
  lo.func_redirect "${@}"
}

lo.func_redirect() {
  [[ $# != 0 ]] && "$@"
}

lo.string_contains() {
  [[ $1 == *"$2"* ]]
}

lo.starts_with() {
  [[ $1 == "$2"* ]]
}

lo.ends_with() {
  [[ $1 == *"$2" ]]
}

lo.replace() {
  lo.func_redirect lo.simple_replace_all "$@"
}

lo.replace_single() {
  printf %s "${1/"$2"/$3}"
}

lo.replace_all() {
  printf %s "${1//"$2"/$3}"
}

lo.func_hack() {
  local target_func=$1
  local marker=$2
  local cond_commands=$3
  local then_code=$4
  local else_code=$5
  if (eval "$cond_commands" >/dev/null 2>&1); then
    local inject_code=$then_code
  else
    local inject_code=$else_code
  fi
  eval "$(lo.replace_all "$(declare -f "$target_func")" "$marker" "$inject_code")"
}

lo.quote() {
  for _ in "$@"; do
    printf %q "$_" HACK_TILDABUG
  done
}
lo.func_hack lo.quote HACK_TILDABUG 'lo.version_ge 4.3' '' '| sed "s/~/\\\\~/g"'

lo.quote() {
  for _ in "$@"; do
    print %q "$_"
  done
}

# caniuse系の関数を固定値にする
while read -r f; do "$f"; eval "$f() { return $?; }"; done < <(declare -F | perl -pe's/^(.*? ){2}//'| grep '^lo\.caniuse_')

