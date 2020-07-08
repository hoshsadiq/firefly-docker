#!/usr/bin/env sh

set -eu

reload_file=/secrets/certs/reload

>&2 echo "INFO: Checking if nginx needs reloading"
if [ -f "$reload_file" ]; then
  nginx -s reload
  rm -f "$reload_file"
fi
