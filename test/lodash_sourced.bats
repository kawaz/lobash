#!/usr/bin/env bats
lobash_path="$BATS_TEST_DIRNAME/../lobash.sh"
lobash_path_q=$(printf %q "$lobash_path")

# shellcheck disable=SC1090
@test "lobash sourced once" {
  [[ -z $LOBASH_VERSION ]]
  . "$lobash_path"
  [[ -n $LOBASH_VERSION ]]
}

# shellcheck disable=SC1090
@test "if same verision lobash sourced twice then skip second loading and return 0." {
  [[ -z $LOBASH_VERSION ]]

  # except: return 0
  (
  . "$lobash_path"
  . "$lobash_path"
  )

  # except: version not change
  (
  . "$lobash_path"
  [[ -n $LOBASH_VERSION ]]
  previous_version=$LOBASH_VERSION
  . "$lobash_path"
  [[ $LOBASH_VERSION == "$previous_version" ]]
  )

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

# shellcheck disable=SC1090,SC2030
@test "if older verision lobash sourced then skip second loading and return 0." {
  [[ -z $LOBASH_VERSION ]]

  # except: return 0
  (
  . "$lobash_path"
  LOBASH_VERSION=530000
  . "$lobash_path"
  )

  # except: version not change
  (
  . "$lobash_path"
  LOBASH_VERSION=530000
  previous_version=$LOBASH_VERSION
  . "$lobash_path"
  [[ $LOBASH_VERSION == "$previous_version" ]]
  )

  # except: The second trace log does not contain the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lobash_path_q
  LOBASH_VERSION=530000
  set -v; . $lobash_path_q
  " 2>&1)
  [[ $vout != *"lo.version_ge() {"* ]]
}

# shellcheck disable=SC1090,SC2030,SC2031
@test "if newer verision lobash sourced then load second loading and return 0." {
  [[ -z $LOBASH_VERSION ]]

  # except: return 0
  (
  . "$lobash_path"
  LOBASH_VERSION=0.0.1
  . "$lobash_path"
  )

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

  # except: The second trace log contains the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lobash_path_q
  LOBASH_VERSION=0.0.1
  set -v; . $lobash_path_q
  " 2>&1)
  [[ $vout == *"lo.version_ge() {"* ]]
}
