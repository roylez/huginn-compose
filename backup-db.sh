#! /bin/bash
# add this to cron
#
#   0 12 * * * /root/huginn/backup_db.sh huginn
#
# to restore:
#   gunzip XXX.db.gz
#   docker-compose exec db pg_restore -C -d <dbname> < XXX.db

# directory to save backups in, must be rwx by postgres user
BASE_DIR="/var/backups/postgres"
YMD=$(date "+%Y-%m-%d")
mkdir -p $BASE_DIR

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH

# make database backup
docker-compose exec db pg_dump -U postgres -Fc $1 | gzip -9 > "$BASE_DIR/$YMD.db.gz"

# delete backup files older than 7 days
OLD=$(find $BASE_DIR -type f -mtime +7)
if [ -n "$OLD" ] ; then
        echo deleting old backup files: $OLD
        echo $OLD | xargs rm -rfv
fi
