#!/bin/bash
set -eo pipefail

## ${LAST_BACKUP:=$(aws s3 --region $AWS_DEFAULT_REGION ls $S3_PATH | awk -F " " '{print $4}' | grep ^$DB_NAME | sort -r | head -n1)}

# Download backup from S3
echo "s3 path: $S3_PATH/$LAST_BACKUP"
aws s3 --region $AWS_DEFAULT_REGION cp $S3_PATH/$LAST_BACKUP $LAST_BACKUP || (echo "Failed to download backup from S3"; exit)

# Restore backup

PGPASSWORD="$DB_PASS" pg_restore -j 4 -Fc -c -d "$DB_NAME" -h "$DB_HOST" -U "$DB_USER" "$LAST_BACKUP"

# If a post extraction command is defined, run it
if [ -n "$AFTER_RESTORE_CMD" ]; then
	eval "$AFTER_RESTORE_CMD" || exit
fi
