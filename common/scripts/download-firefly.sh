#!/usr/bin/env sh

set -eu

if [ -f "$FIREFLY_PATH/version" ] && grep -Fq "$VERSION" "$FIREFLY_PATH/version"; then
  >&2 echo "Firefly is already downloaded. Nothing to do..."
  exit 0
fi

apk add --no-cache php7 \
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
        php7-phar

wget -qO- "https://github.com/firefly-iii/firefly-iii/archive/$VERSION.tar.gz" | \
  tar xzC "$FIREFLY_PATH" --strip-components 1 &

wget -qO- https://getcomposer.org/installer | php &

wait

php composer.phar global require hirak/prestissimo --no-plugins --no-scripts

php composer.phar install \
    --working-dir="$FIREFLY_PATH" \
    --prefer-dist \
    --no-dev \
    --no-scripts \
    --no-interaction \
    --no-progress \
    --no-suggest

php composer.phar dump-autoload --working-dir="$FIREFLY_PATH" --no-interaction

mkdir -p "$FIREFLY_PATH/storage/app/public" \
         "$FIREFLY_PATH/storage/build" \
         "$FIREFLY_PATH/storage/database" \
         "$FIREFLY_PATH/storage/debugbar" \
         "$FIREFLY_PATH/storage/framework/cache/data" \
         "$FIREFLY_PATH/storage/framework/sessions" \
         "$FIREFLY_PATH/storage/framework/testing" \
         "$FIREFLY_PATH/storage/framework/views/twig" \
         "$FIREFLY_PATH/storage/framework/views/v1" \
         "$FIREFLY_PATH/storage/framework/views/v2" \
         "$FIREFLY_PATH/storage/logs" \
         "$FIREFLY_PATH/storage/export" \
         "$FIREFLY_PATH/storage/upload"

chown -R "$USER_CHOWN" "$FIREFLY_PATH"
chmod -R 775 "$FIREFLY_PATH/storage"

rm -rf composer.phar
rm -rf '*/.*' \
      '*/*.md' \
      '*/COPYING' \
      '*/LICENSE' \
      '*/Procfile' \
      '*/*.json' \
      '*/*.lock' \
      '*/phpunit*' \
      '*/nginx_app.conf' \
      '*/crowdin.yml' \
      '*/tests' \
      '*/webpack.mix.js'

echo "$VERSION" > "$FIREFLY_PATH/version"
