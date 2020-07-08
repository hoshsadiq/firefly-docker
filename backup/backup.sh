#!/usr/bin/env sh

set -eu

backup_base_dir="${BACKUP_BASE_DIR:-/backup}"
tmp="$backup_base_dir/tmp"
data="$backup_base_dir/data"

mkdir -p "$tmp" "$data"

lock_file="$tmp/lock"
date_file="$(date +"%Y%m%d%H%M%S")"
backup_dir="$data/$date_file"

postgres_host="${POSTGRES_HOST:-localhost}"
postgres_port="${POSTGRES_PORT:-5432}"
postgres_database="$POSTGRES_DB"
postgres_user="$POSTGRES_USER"
postgres_pass="$POSTGRES_PASSWORD"

_date_time() {
  date +"%Y/%m/%d %H:%M:%S"
}

_utc_date_time() {
  date -u +"%Y/%m/%dT%H:%M:%SZ"
}

_log() {
  level="$1"
  shift
  date_time="$(_date_time)"
  printf "[%s] [%s] %s\n" "$date_time" "$level" "$*"
}

ldebug() {
  _log DEBUG "$@"
}

linfo() {
  _log INFO "$@"
}

lwarn() {
  _log WARN "$@"
}

lerror() {
  _log ERROR "$@"
}

cleanup_files=""
cleanup_dirs=""
cleanup() {
  for file in $cleanup_files; do
    rm -f "$file"
  done
  for dir in $cleanup_dirs; do
    rm -rf "$dir"
  done
}
trap 'cleanup' 0 1 2 3 15

case "${1:-}" in
"--force")
  rm "$lock_file" 2>/dev/null
  ;;
*)
  :
  ;;
esac

if test -f "$lock_file"; then
  lerror "There is another backup process."
  lerror "If not, run the script with --force argument"
  exit 1
fi

touch "$lock_file" 2>/dev/null
cleanup_files="$cleanup_files $lock_file"

mkdir -p "$backup_dir"
cleanup_dirs="$cleanup_dirs $backup_dir"

prefix() {
  prefix="$1"
  shift

  sed -r -e "s/^(\[[^\[]+\] )+/\0[$prefix] /" -e "s#^([^\[])#[$(_date_time)] [DEBUG] [$prefix] \0#"
}

backup() {
  filename="$1"
  shift

  tmp_base="$(mktemp -d -p "$tmp" -t "$filename.XXXXXXXX")"
  pout="$tmp_base/pipe.out"
  perr="$tmp_base/pipe.err"
  mkfifo "$pout" "$perr"
  cleanup_dirs="$cleanup_dirs $tmp_base"

  # Make two background sed processes
  prefix "$filename" <"$pout" &
  prefix "$filename" <"$perr" >&2 &

  {
    linfo "backup started..."
    if ionice -c 3 "$@" >"$pout" 2>"$perr"; then
      linfo "completed successfully..."
    else
      lerror "failed..."
    fi
  } >"$pout" 2>"$perr"
}

echo "$postgres_host:$postgres_port:$postgres_database:$postgres_user:$postgres_pass" >"$PGPASSFILE"
chmod 600 "$PGPASSFILE"
backup "db" pg_dump -f "$backup_dir/db.sql" -h "$postgres_host" -p "$postgres_port" -U "$postgres_user" "$postgres_database"

backup "export" tar -czvf "$backup_dir/export.tar.gz" -C "$backup_base_dir/mnt" export
backup "upload" tar -czvf "$backup_dir/upload.tar.gz" -C "$backup_base_dir/mnt" upload
backup "certificates" tar -czvf "$backup_dir/certificates.tar.gz" -C "$backup_base_dir/mnt" certificates

output_file="$backup_base_dir/tmp/$date_file.tar.gpg"
cleanup_files="$cleanup_files $output_file"

ionice -c 3 gpgtar --sign --encrypt --recipient "$RECIPIENT_ID" -o "$output_file" -C "$backup_dir" .
s5cmd --endpoint-url "$S3_ENDPOINT_URL" cp "$output_file" "s3://$S3_BUCKET/$date_file.tar.gpg"
