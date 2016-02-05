#!/usr/bin/env bats
lodash_path="$BATS_TEST_DIRNAME/../lobash.sh"
lodash_path_q=$(printf %q "$lodash_path")

@test "lodash sourced once" {
  [[ -z $LOBASH_VERSION ]]
  . "$lodash_path"
  [[ -n $LOBASH_VERSION ]]
}

@test "if same verision lodash sourced twice then skip second loading and return 0." {
  [[ -z $LOBASH_VERSION ]]

  # except: return 0
  (
  . "$lodash_path"
  . "$lodash_path"
  )

  # except: version not change
  (
  . "$lodash_path"
  [[ -n $LOBASH_VERSION ]]
  previous_version=$LOBASH_VERSION
  . "$lodash_path"
  [[ $LOBASH_VERSION == "$previous_version" ]]
  )

  # except: The first trace log contains the definition of lo.version_ge()
  vout=$(bash -c "
  set -v; . $lodash_path_q
  set +v; . $lodash_path_q
  " 2>&1)
  [[ $vout == *"lo.version_ge() {"* ]]

  # except: The second trace log does not contain the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lodash_path_q
  set -v; . $lodash_path_q
  " 2>&1)
  [[ $vout != *"lo.version_ge() {"* ]]
}

@test "if older verision lodash sourced then skip second loading and return 0." {
  [[ -z $LOBASH_VERSION ]]

  # except: return 0
  (
  . "$lodash_path"
  LOBASH_VERSION=530000
  . "$lodash_path"
  )


  # except: version not change
  (
  . "$lodash_path"
  [[ -n $LOBASH_VERSION ]]
  LOBASH_VERSION=530000
  previous_version=$LOBASH_VERSION
  . "$lodash_path"
  [[ $LOBASH_VERSION == "$previous_version" ]]
  )

  # except: The second trace log does not contain the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lodash_path_q
  LOBASH_VERSION=530000
  set -v; . $lodash_path_q
  " 2>&1)
  [[ $vout != *"lo.version_ge() {"* ]]
}

@test "if newer verision lodash sourced then load second loading and return 0." {
  [[ -z $LOBASH_VERSION ]]

  # except: return 0
  (
  . "$lodash_path"
  LOBASH_VERSION=0.0.1
  . "$lodash_path"
  )

  # except: version change ot upper
  (
  . "$lodash_path"
  [[ -n $LOBASH_VERSION ]]
  LOBASH_VERSION=0.0.1
  previous_version=$LOBASH_VERSION
  . "$lodash_path"
  [[ $LOBASH_VERSION != "$previous_version" ]]
  lo.version_ge "$LOBASH_VERSION" "$previous_version"
  )

  # except: The second trace log contains the definition of lo.version_ge()
  vout=$(bash -c "
  set +v; . $lodash_path_q
  LOBASH_VERSION=0.0.1
  set -v; . $lodash_path_q
  " 2>&1)
  [[ $vout == *"lo.version_ge() {"* ]]
}
