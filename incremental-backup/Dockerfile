FROM alpine:3.7
LABEL maintainer "Youchen Du <youchen.du@gmail.com>"

RUN apk add --update bash
RUN apk add --update rsync
RUN apk add --update tzdata
RUN rm -rf /var/cache/apk/*

ENV BACKUP_FROM="/media-data" \
    BACKUP_TO="/backup" \
    CRON_TIME="0 1 * * *"

COPY ["entrypoint.sh", "backup.sh", "/"]

RUN chmod u+x /backup.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
