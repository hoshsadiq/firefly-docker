FROM alpine:3.12 as builder

ARG version=2.0

RUN set -eux; \
    apk add python3 python3-dev py3-pip build-base libxml2-dev libxslt-dev jpeg-dev; \
    pip install --quiet --progress-bar on --no-color --upgrade pip; \
    pip install --quiet --progress-bar on --no-color --no-warn-script-location --prefix=/install prettytable termcolor simplejson; \
    pip install --quiet --progress-bar on --no-color --no-warn-script-location --prefix=/install weboob==${version}

FROM alpine:3.12

COPY --from=builder /install/bin /usr/bin/
COPY --from=builder /install/lib /usr/lib/

RUN set -eux; \

    apk add --no-cache \
        ca-certificates \
        gnupg \
        libxslt \
        python3 \
        py3-urllib3 \
        py3-certifi \
        py3-requests \
        py3-six; \

    addgroup -g 808 -S weboob; \
    adduser -u 808 -D -S -G weboob weboob; \

    mkdir -p /home/weboob/.config /home/weboob/.local/share /config /data; \
    ln -s /config /home/weboob/.config/weboob; \
    ln -s /data /home/weboob/.local/share/weboob; \
    chown -R weboob:weboob ~weboob /config /data

USER weboob
WORKDIR "/config"

RUN weboob-config update

ENTRYPOINT weboob
