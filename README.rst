=========================
Docker PostgreSQL Backup
=========================

Docker image that runs a cron job which dumps a Postgres database, and uploads it to an Amazon S3 bucket.

Required environment variables
==============================

* :code:`CRON_SCHEDULE`: The time schedule part of a crontab file (e.g: :code:`15 3 * * *` for every night 03:15)
* :code:`DB_HOST`: Postgres hostname
* :code:`DB_PASS`: Postgres password
* :code:`DB_USER`: Postgres username
* :code:`DB_NAME`: Name of database
* :code:`S3_PATH`: Amazon S3 path in the format: s3://bucket-name/some/path
* :code:`AWS_ACCESS_KEY_ID`
* :code:`AWS_SECRET_ACCESS_KEY`
* :code:`AWS_DEFAULT_REGION`

Optional environment variables
==============================

* :code:`MAIL_TO`: If :code:`MAIL_TO` and :code:`MAIL_FROM` is specified, an e-mail will be sent, using Amazon SES, every time a backup is taken
* :code:`MAIL_FROM`
* :code:`WEBHOOK`: If specified, an HTTP request will be sent to this URL
* :code:`WEBHOOK_METHOD`: By default the webhook's HTTP method is GET, but can be changed using this variable
* :code:`RESTORE`: When set it will CRON schedule automatic restore of database from S3
* :code:`MAX_BACKUP_AGE`: Max backup age of locally kept backups in days. Older backups are deleted at the end of the script
