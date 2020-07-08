# todo is perhaps the base alpine is simpler?
FROM alpine:3.12

ENV FIREFLY_PATH=/var/www/firefly-iii

RUN set -eux; \
    apk add --no-cache \
        bash \
        php7 \
        php7-fpm \
        php7-bcmath \
        php7-curl \
        php7-fileinfo \
        php7-gd \
        php7-intl \
        php7-json \
        php7-openssl \
        php7-pdo \
        php7-session \
        php7-simplexml \
        php7-tokenizer \
        php7-dom \
        php7-xml \
        php7-ldap \
        php7-mbstring \
        php7-iconv \

        # requires one of
        php7-pdo_pgsql \
#        php7-pdo_sqlite \
#        php7-pdo_mysql \

        # optionally if using memcached
        php7-memcached \
        # or redis (managed by composer)
        ; \

    wget -q -O /etc/php7/php.ini https://github.com/php/php-src/raw/php-$(php -r 'echo PHP_VERSION;';)/php.ini-production

# todo: https://grrr.tech/posts/2020/add-locales-to-alpine-linux-docker-image/ ?
#  echo "cs_CZ.UTF-8 UTF-8\nde_DE.UTF-8 UTF-8\nel_GR.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\nes_ES.UTF-8 UTF-8\nfi_FI.UTF-8 UTF-8\nfr_FR.UTF-8 UTF-8\nhu_HU.UTF-8 UTF-8\nid_ID.UTF-8 UTF-8\nit_IT.UTF-8 UTF-8\nnb_NO.UTF-8 UTF-8\nnl_NL.UTF-8 UTF-8\npl_PL.UTF-8 UTF-8\npt_BR.UTF-8 UTF-8\npt_PT.UTF-8 UTF-8\nro_RO.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8\nsv_SE.UTF-8 UTF-8\ntr_TR.UTF-8 UTF-8\nvi_VN.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\nzh_TW.UTF-8 UTF-8\n\n" > /etc/locale.gen && locale-gen

# move this to real image
RUN set -eux; \

    addgroup -g 101 -S www-data; \
    adduser -u 101 -D -S -G www-data www-data; \

    mkdir -p /var/log/php7 $FIREFLY_PATH; \
    ln -svf /dev/stderr /var/log/php7/error.log; \
    ln -svf /dev/stdout /var/log/php7/access.log; \
    chown -R www-data:www-data /var/log/php7 $FIREFLY_PATH; \

    wget -q -O /wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh; \
    chmod +x /wait-for-it.sh

ADD entrypoint.sh /
ADD php/*.ini /etc/php7/conf.d/
ADD php-fpm/*.conf /etc/php7/php-fpm.d/

USER www-data

WORKDIR $FIREFLY_PATH

EXPOSE 9000
#VOLUME $FIREFLY_PATH
VOLUME $FIREFLY_PATH/storage/export $FIREFLY_PATH/storage/upload

ENTRYPOINT ["/entrypoint.sh"]
