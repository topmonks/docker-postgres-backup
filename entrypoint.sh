#!/bin/bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

file_env "DB_PASS"

if [ -z "$CRON_SCHEDULE" ]; then
    echo 'WARNING: $CRON_SCHEDULE not set!'
fi

script=backup
if [ ! -z "$RESTORE" ]; then
  script=restore
fi

# Write cron schedule
echo "#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

$CRON_SCHEDULE root . /backup/$script.sh >> /$script.log 2>&1
" > /etc/cron.d/postgresql-backup

# Env variables that can be imported from backup script,
# since cron jobs doesn't get the environment set
echo "#!/bin/bash

export \"BACKUP_DIR=$BACKUP_DIR\"
export \"BACKUP_FILE_NAME=$BACKUP_FILE_NAME\"
export \"S3_PATH=$S3_PATH\"
export \"DB_NAME=$DB_NAME\"
export \"DB_PASS=$DB_PASS\"
export \"DB_USER=$DB_USER\"
export \"DB_HOST=$DB_HOST\"
export \"MAIL_TO=$MAIL_TO\"
export \"MAIL_FROM=$MAIL_FROM\"
export \"AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID\"
export \"AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY\"
export \"AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION\"
export \"WEBHOOK=$WEBHOOK\"
export \"WEBHOOK_METHOD=$WEBHOOK_METHOD\"
" > /env.sh
chmod +x /env.sh

exec "$@"
