#! /bin/bash
# add this to cron
#
#   0 12 * * * $HOME/huginn/backup_db.sh huginn
#
# to restore:
#   gunzip XXX.db.gz
#   docker-compose exec db pg_restore -Fc -C -d huginn /backup/XXX.db

# directory to save backups in, must be rwx by postgres user
BASE_DIR="/backup"
YMD=$(date "+%Y-%m-%d")

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH

# make database backup
docker-compose exec db pg_dump -U postgres -Fc -d $1 -f "$BASE_DIR/$YMD.db"

# delete backup files older than 7 days
OLD=$(find $BASE_DIR -type f -mtime +7)
if [ -n "$OLD" ] ; then
        echo deleting old backup files: $OLD
        echo $OLD | xargs rm -rfv
fi
