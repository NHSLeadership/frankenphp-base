# NHS Leadership Docker (FrankenPHP)

This is a highly experimental Docker build whilst we test our applications
and PHP extensions with FrankenPHP. The build is subject to change without notice.

## Usage

By default this container runs with it's index at /app.

To modify PHP variables place a .ini file (e.g. 10-nhsla-custom.ini) in /usr/local/etc/php/conf.d

## Cron mode
Override the Dockerfile ENTRYPOINT and CMD definitions as per:

```
ENTRYPOINT ["/usr/local/bin/supercronic"]
CMD ["-overlapping", "-split-logs", "/nhsla/cron"]
```

and place a crontab into /nhsla/cron like this:

```
* * * * * /usr/local/bin/php /app/cron.php
```

## Modifying Caddy

Modify the Caddyfile or overwrite it at /etc/frankenphp/Caddyfile