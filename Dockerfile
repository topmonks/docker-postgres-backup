FROM postgres:10.4

RUN apt-get update && apt-get install -y \
    cron gnupg python-pip

RUN pip install awscli
RUN aws configure set default.s3.signature_version s3v4

VOLUME ["/data/backups"]

ENV BACKUP_DIR /data/backups

ADD . /backup
RUN touch /backup.log

ENTRYPOINT ["/backup/entrypoint.sh"]
CMD cron && tail -f /backup.log
