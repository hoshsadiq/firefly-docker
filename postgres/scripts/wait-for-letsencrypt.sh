#!/usr/bin/env sh

set -eu

until test -f /secrets/certs/ready; do
  sleep 5
done

exec sh /usr/local/bin/run.sh
