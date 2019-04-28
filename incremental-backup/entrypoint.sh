#!/bin/bash
touch /backup.log
tail -F /backup.log &

echo "${CRON_TIME} /backup.sh >> /backup.log 2>&1" > /crontab.conf
crontab /crontab.conf
echo "=> Running cron task manager"
exec crond -f