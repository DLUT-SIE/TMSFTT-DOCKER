#!/bin/bash

if [ ! -d $BACKUP_FROM ] || [ ! -d $BACKUP_TO ]; then
    echo "=> Failed to find src ($BACKUP_FROM) or dest ($BACKUP_TO), Abort."
    exit -1
fi

echo "=> Backup process started  at $(date "+%Y-%m-%d %H:%M:%S")"
rsync -avzx $BACKUP_FROM $BACKUP_TO
echo "=> Backup process finished at $(date "+%Y-%m-%d %H:%M:%S")"