FROM richarvey/nginx-php-fpm:1.5.7
MAINTAINER Szymon Banas <sbanas@trans.eu>

ENV WEBROOT /var/www/html/vhost-service0/public
ENV SKIP_COMPOSER 1

# STAGE 1: CONFIGURE SYSTEM
# Install some commonly used deps
RUN rm -rf /var/cache/apk && \
    mkdir /var/cache/apk
RUN apk upgrade -U \
 && apk add sudo

# STAGE 2: CONFIGURE PHP
RUN ln -s /usr/local/bin/php /usr/bin/php
# Install extensions
# Possible values for ext-name:
#   bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl
#   json ldap mbstring mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql
#   pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap sockets sodium spl
#   standard sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zend_test zip
RUN apk add --no-cache --virtual .phpize-deps ${PHPIZE_DEPS}

RUN docker-php-ext-install \
    opcache \
    bcmath \
    calendar \
    ctype \
    dom \
    exif \
    fileinfo \
    ftp \
    iconv \
    intl \
    json \
    mbstring \
    pdo \
    pdo_mysql \
    pdo_sqlite \
    phar \
    pcntl \
    posix \
    shmop \
    simplexml \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    tokenizer \
    xml \
    xmlwriter \
    xsl \
    wddx \
    zip

RUN apk add --no-cache bzip2-dev \
 && docker-php-ext-install bz2 \
 && apk del --purge bzip2-dev

RUN apk add --no-cache curl-dev libcurl \
 && docker-php-ext-configure curl --with-curl=/usr/local/lib \
 && docker-php-ext-install curl \
 && apk del --purge curl-dev libcurl

RUN apk add --no-cache gettext-dev gettext-libs \
 && docker-php-ext-install gettext \
 && apk del --purge gettext-dev gettext-libs

RUN apk add --no-cache libxml2-dev \
 && CFLAGS="-I/usr/src/php" docker-php-ext-install xmlreader \
 && apk del --purge libxml2-dev

RUN apk add --no-cache rabbitmq-c-dev \
 && pecl install amqp \
 && docker-php-ext-enable amqp

RUN pecl install redis \
 && docker-php-ext-enable redis

# Cleanup
RUN apk del --purge .phpize-deps \
 && rm -rf /var/cache/*

# STAGE 3: CONFIGURE NGINX
RUN rm -Rf /etc/nginx/nginx.conf \
 && rm -Rf /etc/nginx/sites-enabled/*.conf \
 && rm -Rf /etc/nginx/sites-available/*.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/service_vhost0.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Create temp dirs
RUN mkdir -p /var/nginx/client_body_temp \
 && chown nginx:nginx /var/nginx/client_body_temp \
 && mkdir -p /var/cache/nginx/fastcgi_temp \
 && chown nginx:nginx /var/cache/nginx/fastcgi_temp

#
ADD entrypoint.sh /entrypoint.sh
ADD functions.sh /functions.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html/vhost-service0
CMD ["/entrypoint.sh"]