FROM alpine:3.12

ARG version=1.0.0

RUN set -eux; \
    apk add --no-cache gnupg; \
    wget -qO- https://github.com/peak/s5cmd/releases/download/v${version}/s5cmd_${version}_Linux-64bit.tar.gz | \
        tar -xzvf - -C /usr/local/bin s5cmd

COPY setup.sh /setup.sh
COPY backup.sh /backup.sh
#COPY cleanup.sh /cleanup.sh

ENTRYPOINT /setup.sh
