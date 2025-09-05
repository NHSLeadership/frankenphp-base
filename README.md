# NHS Leadership Docker (FrankenPHP)

This is a highly experimental Docker build whilst we test our applications
and PHP extensions with FrankenPHP. The build is subject to change without notice.

This builds upon our old Docker base image configuration, but moves to FrankenPHP/Caddy and
simplifies the container build massively. We assume that we aren't running as root, and only
provide a sane set of defaults for things like e-mail send or PHP configuration. This means
that there is a vastly reduced set of environment variables available upon container start,
and if settings need changing we should do this via Kubernetes ConfigMaps or Docker volume
mounts.

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


# Email Send

We use SSMTP to forward mail upstream. The defaults are to send email to `outbound.kube-mail:25`.


# PHP Sessions

**Redis or a Redis compatible database is required for use of this image.**

Because we run these containers in a Kubernetes cluster it is assumed there will be multiple containers
serving the same site and as such PHP sessions should be centralised. The default host for this is `tcp://redis:6379`.

## Environment Variables

|Variable      |Description      |Default      |
| ------------ | --------------- | ----------- |
|CONTAINER_MODE | web, cron, or worker | web |
|ATATUS_ENABLED | Boolean to enable or disable Atatus APM | false |
|ATATUS_APM_LICENSE_KEY |Provides a licence key to enable the Atatus APM PHP module. Disabled Atatus APM if not set. | |
|ATATUS_ENABLED | The name of the application to be passed to Atatus | "PHP App" |
|REDIS_HOST | Provide the path to Redis for PHP session storage. | tcp://redis:6379 |
|MAIL_RELAY | Set the SMTP mail host for the system's SSMTP mail relay service | outbound.kube-mail:25 |
|APP_ENV | The name of the environment to be passed to Atatus | null |
|APP_VERSION | The version of the app | Set by the upstream container |