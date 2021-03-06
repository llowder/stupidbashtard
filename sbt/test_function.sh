#!/bin/bash

# Copyright 2013 Kyle Harper
# Licensed per the details in the LICENSE file in this package.

function test_function {
  #@Author  Hank BoFrank
  #@Date    2013.03.04
  #@Usage   test_function [-D 'search for string' [-D ...]] [-h --help] [-v --verbose]

  #@Description   A complex function attempting to show most (or all) of the things/ways you can document stuff.
  #@Description   We will attempt to read a file and list the line number and first occurence of a Zelda keyword.
  #@Description   -
  #@Description   This is a SILLY script that is untested; for demonstration purposes only.

  # Variables
  #@$1 The first option (after shifting from getopts) will be a file name to operate on.
  local E_GENERIC=1                      #@$E_GENERIC If we need to exit and don't have a better ERROR choice, use this.
  local E_BAD_INPUT=10                   #@$ Send when file specified in $1 is invalid or when -D is blank.
  local VERBOSE=false                    #@$VERBOSE Flag to decide if we should be chatty with our output.
  local temp='something'                 #@$ A temp variable for our operations below.  (Note: Docker will record defaults.)
  declare -r local wife_is_hot=true      #@$ Pointless boolean flag, and it is now read only (and accurate).
  declare -a local index_array=( Zelda ) #@$ Index array with 1 element (element 0, value of Zelda)
  declare -A local assoc_array           #@$ Associative array (hash) to hold misc things as we read file.
  declare -i local i                     #@$ A counter variable, forced to be integer only.
  final_value=''                         #@$ The final value to expose to the caller after we exit. (Note: Docker will flag as by-ref.)

  # Process options
  while core_getopts ":D:hv" opt 'help,verbose'; do
    case $opt in
      D           ) #@opt_ Add bonus items to the index_array variable.
                    index_array+=("${OPTARG}")
                    ;;
      h|help      ) #@opt_     Display an error and return non-zero if the user tries to use -h for this function.
                    echo 'No help exists for this function yet.' >&2
                    return ${E_GENERIC}
                    ;;
      v | verbose ) VERBOSE=true ;; #@opt_ Change the verbose flag to true so we can send more output to the caller.
      \?          ) echo "Invalid option: -$OPTARG" >&2 ; return ${E_GENERIC} ;;
    esac
  done

  # Pre-flight Checks
  if ! core_ToolExists 'grep'     ; then echo 'The required tools to run this function were not found.' >&2 ; return ${E_GENERIC}   ; fi
  if [ ${#index_array[@]} -lt 2 ] ; then echo "You must provide at least 1 Hyrule item (via -D option)" >&2 ; return ${E_BAD_INPUT} ; fi
  if [ ! -f ${1} ]                ; then echo "Cannot find specified file to read: ${1}"                >&2 ; return ${E_BAD_INPUT} ; fi
  ${VERBOSE} && echo "Verbosity enabled.  Done processing variables and cleared pre-flight checks."

  # Main function logic
  i=1
  while read line ; do
    # If the line matches a Hyrule keyword, store it in associative array.  Use grep, simply so we can add it to core_ToolExists check above.
    for temp in ${index_array[@]} ; do
      if echo "${line}" | grep -q -s ${temp} ; then assoc_array["${i}"]="${temp}" ; break ; fi
    done
    let i++
  done <$1

  # Print results & leave
  if [ ${#assoc_array[@]} -eq 0 ] ; then echo "No matches found." ; return 0 ; fi
  for temp in ${!assoc_array[@]} ; do echo "Found match for keyword ${assoc_array[${temp}]} on line number ${temp}." ; done
  return 0
}

