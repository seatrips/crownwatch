#!/bin/bash
# crownwatch.sh
# 
# A watchdog program to alleviate problems caused by increased memory
# usage of the send daemon. 
# It is expected to be installed as /usr/local/bin/crownwatch.sh and 
# executed by whichever userid runs the daemon on your system, by cron 
# every 15 minutes. Add the following (uncommented) line to make it so
# */15 * * * * /usr/local/bin/crownwatch.sh 
#
# It does 2 things:
#  1. Check if sendd is running and start it if not
#  2. Check how much memory is free and pre-emptively restart the
#     daemon if it is judged too low. The default amount is rather
#     arbitrary and may not be appropriate for everyone. That's why
#     it is easily configurable a few lines down from here where it
#     says    MINFREE=524288
#
# TODO:
#  1. Assumes there is swap defined. Check if there is and configure some 
#     if not.

# Customise these to suit your environment
MINFREE=150288                  # safe minimum free memory
PREFIX="/usr/local/bin"         # path to send executables
DATADIR=~/.send                # send datadir

# Announce ourselves
echo "send watchdog script running at" `date`

# Start off by looking for running daemon
PID=$(pidof sendd)

# Start it if it's not running
if [[ $? -eq 1 ]]; then
  echo "sendd not running. Removing any old flags and starting it."
  rm -f "${DATADIR}/sendd.pid" "${DATADIR}/.lock"
  ${PREFIX}/sendd -daemon

# Check free memory if it is running
else
  echo "sendd running with PID=${PID}. Checking free memory."
  TMP=$("mktemp")
  free > ${TMP}
  FREEMEM=$(awk '$1 ~ /Mem|Swap/ {sum += $4} END {print sum}' ${TMP})
  rm ${TMP}

# If free memory is getting low, pre-emptively stop the daemon
  if [[ ${FREEMEM} -lt ${MINFREE} ]]; then
    echo "Total free memory is less than minimum. Shutting down sendd."
    ${PREFIX}/send-cli stop

# Allow up to 10 minutes for it to shutdown gracefully
    for ((i=0; i<10; i++)); do
      echo "...waiting..."
      sleep 60
      if  [[ $(ps -p ${PID} | wc -l) -lt 2 ]]; then
        break
      fi
    done

# If it still hasn't shutdown, terminate with extreme prejudice
    if [[ ${i} -eq 10 ]]; then
      echo "Shutdown still incomplete, killing the daemon."
      kill -9 ${PID}
      sleep 10
      rm -f "${DATADIR}/sendd.pid" "${DATADIR}/.lock"
    fi

# Restart it if we stopped it
    echo "Starting sendd."
    ${PREFIX}/sendd -daemon

# Nothing to do if there was enough free memory
  else
    echo "Total free memory is above safe minimum, doing nothing."
  fi
fi
