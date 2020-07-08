FROM postgres:12-alpine

RUN apk add runit && \
    sed -i -r '/^postgres:/s#:[^$:]+$#:/sbin/nologin#' /etc/passwd

ENV SVDIR=/etc/service

ADD scripts/ /usr/local/bin
ADD runit/ $SVDIR

ENTRYPOINT /usr/local/bin/wait-for-letsencrypt.sh

