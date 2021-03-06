#!/bin/bash

# Copyright 2013 Kyle Harper
# Licensed per the details in the LICENSE file in this package.

# Source shared, core, and namespace.
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../__shared.inc.sh"
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../sbt/core.sh"
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../sbt/string.sh"


# Performance check
if [ "${1}" == 'performance' ] ; then iteration=1 ; START="$(date '+%s%N')" ; else echo '' ; fi


# Testing loop
while [ ${iteration} -le ${MAX_ITERATIONS} ] ; do
  # -- 1 -- Simple invocation with expected parameters
  new_test "Sending expected arguments for a normal usage: "
  [ "$(string_PadBoth -l 20 -p '-' 'some_string')" == '----some_string-----' ]  || fail 1
  [ "$(string_PadBoth -l 21 -p '-' 'some_string')" == '-----some_string-----' ] || fail 2
  pass

  # -- 2 -- Saving results in reference variable
  new_test "Storing results in reference variable: "
  rv=''
  string_PadBoth -l 20 -p '-' 'some_string' -R 'rv'
  [ "${rv}" == '----some_string-----' ] || fail 1
  rv=''
  string_PadBoth -l 21 -p '-' 'some_string' -R 'rv'
  [ "${rv}" == '-----some_string-----' ] || fail 2
  pass

  # -- 3 -- Reading from a file for kicks.
  new_test "Reading data from a file just because: "
  echo 'some_string' >/tmp/string_Pad.tmp
  [ "$(string_PadBoth -l 20 -p '-' -f '/tmp/string_Pad.tmp')" == '----some_string-----' ]   || fail 1
  [ "$(string_PadBoth -l 21 -p '-' -f '/tmp/string_Pad.tmp')" == '-----some_string-----' ]  || fail 2
  pass
  rm /tmp/string_Pad.tmp

  # -- 4 -- Not specifying required items should fail
  new_test "Length is required, checking: "
  string_PadBoth -p '-' 'random junk' 2>/dev/null 1>/dev/null && fail 1
  pass

  # -- 5 -- Defaults shouldn't change
  new_test "Pad string and direction have defaults, ensuring they persist: "
  [ "$(string_PadBoth        -l 20        'some_string')" == '    some_string     ' ]  || fail 1
  [ "$(string_PadBoth        -l 21        'some_string')" == '     some_string     ' ] || fail 2
  pass

  let iteration++
done


# Send final data
if [ "${1}" == 'performance' ] ; then
  END="$(date '+%s%N')"
  let "TOTAL = (${END} - ${START}) / 1000000"
  let "TPS   = ${test_number} / (${TOTAL} / 1000)"
  printf "  %'.0f tests in %'.0f ms (%s tests/sec)\n" "${test_number}" "${TOTAL}" "$(bc <<< "scale = 3; ${test_number} / (${TOTAL} / 1000)")" >&2
fi
