# nginx-php-fpm

Nginx and PHP-FPM in single image

## Whats inside?
- Nginx
- PHP-FPM
- Supervisord

## Environment variables

| Variable name | Default value | Description
|----|----|----|
| SERVER_NAME | *None* | Nginx `server_name` directive value |

More flags from base image - [click](https://gitlab.com/ric_harvey/nginx-php-fpm/blob/master/docs/config_flags.md)

## Quick Start
To pull from docker hub:
```
docker pull banny310/nginx-php-fpm:latest
```

### Running
To simply run the container (in background):
```
sudo docker run -d -v $(pwd):/var/www/html/vhost-service0 banny310/nginx-php-fpm
```

### Enter into container
To simply run the container:
```
sudo docker run -it banny310/nginx-php-fpm bash
```

## Code deploy
Application code should be placed at `/var/www/html/vhost-service0`.

At the same time nginx root directory is pointed at `/var/www/html/vhost-service0/public`

## Post deploy scripts
At runtime script executes two scripts (keeping the order):
- `./cardbox.d/pre-install.sh`
- `./cardbox.d/post-install.sh`

## Daemon inside container
To register daemon process inside container simply provide supervisord compatible config into `/etc/supervisor/conf.d/`
You may do it within `post-install.sh` script.
Example.:
```
cat > /etc/supervisor/conf.d/fleet.conf << EOF
[program:fleet-queue-rabbitmq]
process_name=fleet_rabbitmq_cli
command=/usr/bin/php -d memory_limit=-1 public/index.php ltgroup:queue:smart-consume rabbitmq --max-instances=2 --watch-interval=5
environment=APPLICATION_ENV="%APP_ENV%"
directory=%APP_ROOT%
user=%APP_USER%
autostart=true
autorestart=true
priority=100
stdout_events_enabled=true
stderr_events_enabled=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stopsignal=QUIT
EOF
```