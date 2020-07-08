#!/usr/bin/env sh

set -eu

# todo use certbot hook to create a file, and wait for that
until nginx -t >/dev/null 2>&1; do
  sleep 5
done
