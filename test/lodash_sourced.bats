#!/usr/bin/env bats

setup() {
  lobash_path="$BATS_TEST_DIRNAME/../lobash.sh"
  lobash_path_q=$(printf %q "$lobash_path")
}

# shellcheck disable=SC1090
@test 'When lobash sourced, it set $LOBASH_VERSION.' {
  [[ -z $LOBASH_VERSION ]]
  . "$lobash_path"
  [[ -n $LOBASH_VERSION ]]
}

# shellcheck disable=SC1090
@test "When same verision lobash sourced twice, it success." {
  [[ -z $LOBASH_VERSION ]]
  # except: return 0
  (
  . "$lobash_path"
  . "$lobash_path"
  )
}

# shellcheck disable=SC1090
@test 'When same verision lobash sourced twice, dont change $LOBASH_VERSION.' {
  # except: version not change
  (
  . "$lobash_path"
  [[ -n $LOBASH_VERSION ]]
  previous_version=$LOBASH_VERSION
  . "$lobash_path"
  [[ $LOBASH_VERSION == "$previous_version" ]]
  )
}

# shellcheck disable=SC1090
@test "When same verision lobash sourced twice, break second loading." {
  # except: The first trace log contains the definition of lo.version_ge()
  vout=$(bash -c "
  set -v; . $lobash_path_q
  set +v; . $lobash_path_q
  " 2>&1)
  [[ $vout == *"lo.version_ge() {"* ]]
  # except: The second trace log does not contain the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lobash_path_q
  set -v; . $lobash_path_q
  " 2>&1)
  [[ $vout != *"lo.version_ge() {"* ]]
}

# shellcheck disable=SC1090
@test "When older verision lobash sourced, it success." {
  [[ -z $LOBASH_VERSION ]]
  (
  . "$lobash_path"
  LOBASH_VERSION=530000
  . "$lobash_path"
  )
}

# shellcheck disable=SC1090,SC2030
@test 'When older verision lobash sourced, dont change $LOBASH_VERSION.' {
  # except: version not change
  (
  . "$lobash_path"
  LOBASH_VERSION=530000
  previous_version=$LOBASH_VERSION
  . "$lobash_path"
  [[ $LOBASH_VERSION == "$previous_version" ]]
  )
}

# shellcheck disable=SC1090
@test "When older verision lobash sourced twice, break second loading." {
  # except: The second trace log does not contain the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lobash_path_q
  LOBASH_VERSION=530000
  set -v; . $lobash_path_q
  " 2>&1)
  [[ $vout != *"lo.version_ge() {"* ]]
}

# shellcheck disable=SC1090,SC2030,SC2031
@test "When newer verision lobash sourced, it success." {
  [[ -z $LOBASH_VERSION ]]
  # except: return 0
  (
  . "$lobash_path"
  LOBASH_VERSION=0.0.1
  . "$lobash_path"
  )
}

# shellcheck disable=SC1090,SC2031
@test 'When newer verision lobash sourced, change $LOBASH_VERSION to newer.' {
  # except: version change ot upper
  (
  . "$lobash_path"
  [[ -n $LOBASH_VERSION ]]
  LOBASH_VERSION=0.0.1
  previous_version=$LOBASH_VERSION
  . "$lobash_path"
  [[ $LOBASH_VERSION != "$previous_version" ]]
  lo.version_ge "$LOBASH_VERSION" "$previous_version"
  )
}

@test 'When newer verision lobash sourced, dont break loading.' {
  # except: The second trace log contains the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lobash_path_q
  LOBASH_VERSION=0.0.1
  set -v; . $lobash_path_q
  " 2>&1)
  [[ $vout == *"lo.version_ge() {"* ]]
}
