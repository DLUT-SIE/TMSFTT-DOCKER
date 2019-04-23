#!/bin/bash
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
[ -z "${MYSQL_PASS:=$MYSQL_PASSWORD}" ] && { echo "=> MYSQL_PASS cannot be empty" && exit 1; }

DATE=$(date +%Y%m%d%H%M)
echo "=> Backup started at $(date "+%Y-%m-%d %H:%M:%S")"
databases=${MYSQL_DATABASE:-${MYSQL_DB:-$(mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)}}
BASEDIR=/backup/"$DATE"
mkdir $BASEDIR
for db in $databases
do
  if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]]
  then
    echo "==> Dumping database: $db"
    FILENAME=$BASEDIR/$db.sql
    LATEST=/backup/latest.$db.sql.gz
    if mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" --databases "$db" $MYSQLDUMP_OPTS > "$FILENAME"
    then
      gzip -f "$FILENAME"
      echo "==> Creating symlink to latest backup: $(basename "$FILENAME".gz)"
      rm "$LATEST" 2> /dev/null
      ln -s "$FILENAME".gz "$LATEST"
    else
      rm -rf "$DATE"
    fi
  fi
done
if [ "$BACKUP_MEDIA" -eq "1" ]
then
  echo "==> Copying media files"
  cp -r /media $BASEDIR
  cd $BASEDIR
  tar -zcf media.tar.gz media
  rm -rf media
  cd /
  echo "==> Media files copied"
fi

if [ -n "$MAX_BACKUPS" ]
then
  echo "=> Max number of backups ("$MAX_BACKUPS") reached. Deleting oldest backups"
  while [ "$(find /backup -maxdepth 1 -mindepth 1 -type d | wc -l)" -gt "$MAX_BACKUPS" ]
  do
    TARGET=$(find /backup -maxdepth 1 -mindepth 1 -type d | sort | head -n 1)
    rm -rf "$TARGET"
    echo "==> Backup $TARGET has been deleted"
  done
fi

echo "=> Backup process finished at echo $(date "+%Y-%m-%d %H:%M:%S")"
