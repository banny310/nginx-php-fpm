#!/usr/bin/env bash

function die()
{
  [ -n "$1" ] && echo "$1"
  exit 1
}

function is_defined()
{
    if [[ ! -v $1 ]]; then
        echo "Missing $1!"
        exit 1
    fi
}

function register_global()
{
    if [[ -v $1 ]]; then
        eval val=\$$1
        echo "$1=\"$val\"" | tee -a /etc/environment
    else
        echo "Missing $1!"
        exit 1
    fi
}

# Execute given script and check its return code
#
# Usage: runScript /var/post-install.sh
#
function runScript()
{
    printf "Executing script %s\n" $1
    if [ -f $1 ]; then
        # Make script executable in case they aren't
        chmod a+x $1; sync;

        # Execute
        bash $1
        if [ $? -eq 0 ]; then
            printf "Successfully executed %s\n" $1
        else
            printf "Script %s exited with non zero code\n" $1
            exit 1
        fi
    else
        printf "Script %s does not exists. Skipping...\n" $1
    fi
}

# Install or update Composer in given location
#
# Usage: getComposer /usr/local/bin
#
function getComposer()
{
    if [ -z $1 ]; then
        printf "Install directory not provided"
        exit 1
    fi

    if [ -e $1/composer ]; then
        $1/composer self-update
    else
        curl -sS https://getcomposer.org/installer | php -- --install-dir=$1 --filename=composer
    fi
}

# Send custom message on hipchat token
#
# Usage: hipchatSendMessage 4304004 20Y2UeUV0h5CU5oqhSXhi6a53ZkuWaDsAxcvFlPM "This is message"
#
function hipchatSendMessage()
{
    if [ ! $1 ] || [ ! $2 ] || [ ! $3 ]; then
        echo "Please enter a ROOM id, ROOM token and MESSAGE"
        exit 1
    fi

    ROOM=$1
    TOKEN=$2
    MESSAGE=$3
    curl -X POST https://api.hipchat.com/v2/room/${ROOM}/notification?auth_token=${TOKEN} \
        -H 'content-type: application/json' \
        -d '{"notify": true,"color":"purple","message_format":"html","message":"'${MESSAGE}')"}'
}