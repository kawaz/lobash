#!/bin/bash

# shellcheck disable=SC2155,SC2154
equals_var() {
  local left_declare=$(declare -p "$1" 2>/dev/null)
  local right_declare=$(declare -p "$2" 2>/dev/null)
  [[ -z $left_declare || -z $right_declare ]] && return 1
  # 属性を取得
  local left_attr=${left_declare#*-}; left_attr=${left_attr%% *}
  local right_attr=${right_declare#*-}; right_attr=${left_attr%% *}
  # 属性を取得
  local left_attr=${left_declare#*-}; left_attr=${left_attr%% *}
  local right_attr=${right_declare#*-}; right_attr=${left_attr%% *}
  # declare -p の出力をevalすることで配列含め変数のクローンを簡単に作れる
  eval "${left_declare/$1=/left=}"
  eval "${right_declare/$2=/right=}"
  # 非配列
  if [[ $left_attr$right_attr != *[aA]* ]]; then
    [[ $left == "$right" ]]; return $?
  fi
  # 配列or連想配列
  [[ ${#left[@]} == "${#right[@]}" ]] || return 1
  [[ $left_attr$right_attr == *a*A* ]] || return 1
  [[ $left_attr$right_attr == *A*a* ]] || return 1
  # local left_idx=("${!left[@]}")
  # local right_idx=("${!right[@]}")
  # (echo $1 $2 $3;IFS=$'\n';echo "${!equals_var__right[*]}")
  # (equals_var equals_var__left_idx equals_var__right_idx inner) || return 1
  for _ in "${!left[@]}" "${!right[@]}"; do
    [[ ${left[$_]} == "${right[$_]}" ]] || return 1
  done
}

