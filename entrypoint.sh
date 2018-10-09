#!/usr/bin/env bash

set -e

source /functions.sh

APP_ROOT=/var/www/html/vhost-service0
CARDBOX_ROOT=${APP_ROOT}/cardbox.d
COMPOSER_DIR=/usr/local/bin

# Install or update Composer
getComposer ${COMPOSER_DIR}

# Update server_name
if [ ! -z "${SERVER_NAME}" ]; then
    sed -i "s/server_name _;/server_name ${SERVER_NAME};/" /etc/nginx/sites-available/default.conf
fi

# Run pre installation scripts
runScript ${CARDBOX_ROOT}/pre-install.sh

# MAYBE something here

# Run post installation scripts
runScript ${CARDBOX_ROOT}/post-install.sh

# Redirect to original image script
(/start.sh && exit 0) || exit 1