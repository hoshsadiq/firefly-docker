#!/usr/bin/env sh

shutdown() {
  echo "shutting down container"

  sv stop "$SVDIR"/*

  # shutdown runsvdir command
  kill -HUP $RUNSVDIR
  wait $RUNSVDIR

  # give processes time to stop
  sleep 1

  # kill any other processes still running in the container
  for _pid in $(ps -eo pid | tail -n +2 | grep -v '^1$' | head -n -5); do
    timeout -t 5 /bin/sh -c "kill $_pid && wait $_pid" || kill -9 "$_pid"
  done
}

# todo this need to be configurable
echo '0 6 * * * sh /usr/local/bin/reload-postgres' | crontab -

# store environment variables
export > /etc/envvars

exec runsvdir -P "$SVDIR" &

RUNSVDIR=$!
echo "Started runsvdir, PID is $RUNSVDIR"
echo "wait for processes to start...."

sleep 5
sv status "$SVDIR/"*

# catch shutdown signals (SIGHUP, SIGINT, SIGQUIT, SIGTERM)
trap shutdown 1 2 3 15
wait $RUNSVDIR

shutdown
