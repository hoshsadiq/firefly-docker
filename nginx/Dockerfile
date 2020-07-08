FROM nginx:stable-alpine

RUN apk add runit && mkdir -p /run/nginx

ENV SVDIR=/etc/service

ADD crond/ /cron/
ADD runit/ $SVDIR
ADD scripts/run.sh /

ENTRYPOINT /run.sh
