FROM debian:12-slim

RUN apt update && \
  apt install curl wget gpg -y && \
  curl https://frankenphp.dev/install.sh | sh && \
  curl https://s3.amazonaws.com/atatus-artifacts/gpg/atatus.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/atatus.gpg && \
  echo "deb https://s3.amazonaws.com/atatus-artifacts/atatus-php/debian stable main" | tee -a /etc/apt/sources.list.d/atatus-php-agent.list && \
  echo "deb https://s3.amazonaws.com/atatus-artifacts/atatus-php/debian stable main" | tee -a /etc/apt/sources.list.d/atatus-php-agent.list && \
  apt update && \
  cd /tmp && \
  apt download atatus-php-agent --no-install-recommends && \
  dpkg-deb -R atatus-php-agent*.deb ./extract