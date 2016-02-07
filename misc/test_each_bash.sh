#!/usr/bin/env bash
set -e

repo_home=$(cd "$(dirname "$0")/.." && pwd)
[[ -n $repo_home ]]

bats_home="$repo_home/.cache/bats"
if [[ ! -d $bats_home ]]; then
  git clone https://github.com/sstephenson/bats.git "$bats_home"
fi

run_test() {
  set +e
  local v=$1
  local bash_home="$repo_home/.cache/bash-$v"
  local restrict_path="$bats_home/bin:$bash_home/bin:/usr/bin:/bin"
  env -- PATH="$restrict_path" bash --version
  env -- PATH="$restrict_path" bats --pretty ./test
  return
}

list_version() {
  local v
  for d in "$repo_home/.cache/bash"-*; do
    [[ -d $d ]] && echo "${d##*-}"
  done
}

if [[ $# == 0 ]]; then
  exec >&2
  echo "Usage: $0 [all|default] [version [version..]]"
  echo "  support bash versions are: $(list_version|perl -pe's/\s+/ /s')"
  exit 1
fi

for v in "$@"; do
  case $v in
    all)
      list_version | while read -r v1; do run_test "$v1"; done
      ;;
    default)
      run_test "$(dirname "(type -p bash)")"
      ;;
    *)
      run_test "$v"
      ;;
  esac
done
