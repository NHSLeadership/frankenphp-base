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
|ATATUS_ENABLED | Boolean to enable or disable Atatus APM | false |
|ATATUS_APM_LICENSE_KEY |Provides a licence key to enable the Atatus APM PHP module. Disabled Atatus APM if not set. | |


|BUILD |A build number from your CICD system, used to form the app version in Atatus. | |
|ENVIRONMENT |Name of environment container is deployed to. Mainly used to configure PHP logging and the Atatus release stage | |
| MAIL_HOST | Set the SMTP mail host for the system's SSMTP mail relay service | outbound.kube-mail |
| MAIL_PORT | Set the SMTP mail port for the system's SSMTP mail relay service | 25 |
| REDIS_SESSIONS | Tells PHP FPM to use Redis for a session store. | false |
| REDIS_HOST | Combined with above. Sets the redis hostname and port | redis:6379 |
| ROLE | Set to CRON or WORKER on the PHP-FPM container to swap the php-fpm service for supercronic. Place cron files in /nhsla/cron |  |
| SITE_NAME | A name for the site. Mainly used for the Atatus application name |  |
| SITE_BRANCH | A branch from your code repository. Used to form the app version in Atatus |  |