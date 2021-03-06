#!/bin/sh

set -eo pipefail

# Start endless loop
while :
do

  # Check for connections that should be available
  echo "[$(date +"%d/%m/%Y %H:%M:%S") | DEBUG] Check hosts from allow.lst to be available"

  # Loop over the file `allow.lst`
  for target in $(cat cfg/allow.lst)
  do

    # Try to connect 
    echo foo | ncat $(echo $target | tr ":" " ") > /dev/null 2>&1

    # Evaluate previous command result
    if [[ $? != 0 ]]
    then

      # Exit sctipt with error code if it is not possible to connect
      echo "[$(date +"%d/%m/%Y %H:%M:%S") | ERROR] $target is not accessible, but should be !!"
      exit 1

    else
      echo "[$(date +"%d/%m/%Y %H:%M:%S") | INFO] $target is accessible"
    fi
  done

  # Check for connections that should NOT be available
  echo "[$(date +"%d/%m/%Y %H:%M:%S") | DEBUG] Check hosts from deny.lst to be not available"

  # Loop over the file `deny.lst`
  for target in $(cat cfg/deny.lst)
  do

    # Try to connect
    echo foo | ncat $(echo $target | tr ":" " ") > /dev/null 2>&1

    # Evaluate previous command result 
    if [[ $? != 0 ]]
    then
      echo "[$(date +"%d/%m/%Y %H:%M:%S") | INFO] $target not accessible"
    else

      # Exit sctipt with error code if it is possible to connect
      echo "[$(date +"%d/%m/%Y %H:%M:%S") | ERROR] $target is accessible, but should not be !!"
      exit 1

    fi
  done

  # Check if the test should be performed continiously
  if [[ ! -z "$REPEAT_AFTER" && $REPEAT_AFTER != 0 ]]
  then
    
    # wait configured timeout
    echo "[$(date +"%d/%m/%Y %H:%M:%S") | DEBUG] wait $REPEAT_AFTER seconds and repeat"
    sleep $REPEAT_AFTER
  else

    # stop loop
    break

  fi
done

exit 0
