FROM debian:12-slim

RUN apt update && \
  apt install curl wget gpg tini -y && \
  curl https://frankenphp.dev/install.sh | sh && \
  mv frankenphp /usr/local/bin/ && \
  mkdir -p /usr/lib/frankenphp/modules && \
  mkdir -p /etc/frankenphp && \
  cd /tmp && mkdir extract && \
  wget -O atatus.tar.gz https://s3.amazonaws.com/atatus-artifacts/atatus-php/downloads/atatus-php-1.17.0-x64-debian.tar.gz -O atatus.tar.gz && \
  tar -xzf atatus.tar.gz -C extract --strip-components=1 && \
  mv /tmp/extract/usr/bin/atatus-php-collector /usr/bin/atatus-php-collector && \
  mv /tmp/extract/usr/lib/atatus-php/x86_64/atatus_php_zts_8.4.so /usr/lib/frankenphp/modules/atatus.so && \
  mkdir /etc/atatus && mkdir /etc/frankenphp/php.d && \
  mkdir -p /var/log/atatus && touch /var/log/atatus/collector.log

ADD atatus.ini /etc/frankenphp/php.d/atatus.ini
ADD atatus-php-collector.conf /etc/atatus/atatus-php-collector.conf
ADD php.ini /etc/frankenphp/php.ini
ADD index.php /app/index.php

ENTRYPOINT ["/usr/bin/tini", "--"]
#CMD ["/usr/local/bin/frankenphp", "php-server", "--access-log", "--root", "/app"]
CMD ["/bin/sh", "-c", "/usr/bin/atatus-php-collector & exec /usr/local/bin/frankenphp php-server --access-log --root /app"]