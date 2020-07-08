#!/usr/bin/env sh

set -eux

gpg --import /backup/keys/recipient.key
gpg --import /backup/keys/sign.key

RECIPIENT_ID="$(gpg --with-colons --keyid-format 0xlong --with-subkey-fingerprint --import-options show-only --import < /backup/keys/recipient.key | awk -F: '/^pub:/{c++}; /^fpr:/ && c==1 { print $10; exit }' )"
SIGN_ID="$(gpg --with-colons --keyid-format 0xlong --with-subkey-fingerprint --import-options show-only --import < /backup/keys/sign.key | awk -F: '/^sec:/{c++}; /^fpr:/ && c==1 { print $10; exit }' )"
export RECIPIENT_ID SIGN_ID

cat <<EOF | gpg --import-ownertrust
$RECIPIENT_ID:6:
$SIGN_ID:6:
EOF

echo "$BACKUP_SCHEDULE /backup.sh" | crontab -

exec crond -f -L /dev/stdout
