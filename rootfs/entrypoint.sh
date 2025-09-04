#!/bin/bash
set -e

# Startup logging
echo "=== Container Startup ==="
echo "Container mode: ${CONTAINER_MODE:-web}"
echo "Environment: ${APP_ENV:-production}"
echo "Atatus: ${ATATUS_ENABLED:-false}"
echo "Mail relay: ${MAIL_RELAY:-outbound.kube-mail:25}"
echo "PHP session host: ${REDIS_HOST:-tcp://redis:6379}"
echo "Timestamp: $(date)"

# Run any pre-startup scripts
if [ -f "/pre-entrypoint.sh" ]; then
    echo "Running pre-startup script..."
    bash /pre-entrypoint.sh
fi

# Create rw config directory if it doesnt exist
# Usually if we're running outside our K8s environment
mkdir -p /nhsla/rw

# Setup Atatus
# The php config ini for Atatus is symlinked from /usr/local/etc/php/conf.d/a-atatus.ini to /nhsla/roconfig/atatus.ini
cp /nhsla/ro/atatus.ini /nhsla/rw/atatus.ini
if [ "${ATATUS_ENABLED:-false}" = "true" ] && [ ! -z "$ATATUS_APM_LICENSE_KEY" ]; then
  # If Atatus is enabled and API key set then configure Atatus
  sed -i -e "s/atatus.license_key = \"\"/atatus.license_key = \"$ATATUS_APM_LICENSE_KEY\"/g" /nhsla/rw/atatus.ini
  sed -i -e "s/atatus.app_name = \"PHP App\"/atatus.app_name = \"$APP_NAME\"/g" /nhsla/rw/atatus.ini
  sed -i -e "s/atatus.release_stage = \"production\"/atatus.release_stage = \"$APP_ENV\"/g" /nhsla/rw/atatus.ini
  sed -i -e "s/atatus.app_version = \"\"/atatus.app_version = \"$APP_VERSION\"/g" /nhsla/rw/atatus.ini
fi
#####

# Setup email relay
# The config for this is symlinked from /etc/ssmtp.conf to /nhsla/rw/ssmtp.conf
cp /nhsla/ro/ssmtp.conf /nhsla/rw/ssmtp.conf
if [ ! -z "$MAIL_RELAY" ]; then
  sed -i -e "s|mailhub=.*|mailhub=$MAIL_RELAY|g" /nhsla/rw/ssmtp.conf
fi
if [ ! -z "$MAIL_ROOT" ]; then
  sed -i -e "s|root=.*|root=$MAIL_ROOT|g" /nhsla/rw/ssmtp.conf
fi
if [ ! -z "$MAIL_FROM_LINE_OVERRIDE" ]; then
  sed -i -e "s|FromLineOverride=.*|FromLineOverride=$MAIL_FROM_LINE_OVERRIDE|g" /nhsla/rw/ssmtp.conf
fi

# Override the Redis session host
cp /nhsla/ro/phpsess.ini /nhsla/rw/phpsess.ini
#if [ ! -z "$PHP_SESSION_HANDLER" ]; then
#  sed -i -e "s|session.save_handler = .*|session.save_handler = $PHP_SESSION_HANDLER|g" /nhsla/rw/phpsess.ini
#fi
if [ ! -z "$REDIS_HOST" ]; then
  sed -i -e "s|session.save_path = .*|session.save_path = \"$REDIS_HOST\"|g" /nhsla/rw/phpsess.ini
fi



# Environment-specific setup
case "${APP_ENV:-production}" in
    "development"|"dev")
        echo "Development mode"
        ;;
    "staging")
        echo "Staging mode"
        ;;
    "production"|"prod")
        echo "Production mode"
        ;;
esac

# Container mode logic
case "${CONTAINER_MODE:-web}" in
    "cron")
        echo "Starting cron container..."
        exec /usr/local/bin/supercronic -overlapping -split-logs /nhsla/cron
        ;;
    "worker")
        echo "Starting worker container..."
        exec php /app/artisan queue:work --sleep=3 --tries=3
        ;;
    "web"|*)
        echo "Starting web server..."
        exec docker-php-entrypoint frankenphp run --config /etc/frankenphp/Caddyfile
        ;;
esac