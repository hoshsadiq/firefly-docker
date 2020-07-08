#!/usr/bin/env sh

set -eu

until test -f "$FIREFLY_PATH/vendor/autoload.php"; do
  sleep 1
done

sleep 1

exec "$@"
