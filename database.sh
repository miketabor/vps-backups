#!/bin/bash
################################################
#
# Backup all MySQL databases in separate files and compress each file.
# NOTES:
# - MySQL and pigz must be installed on the system
# - Requires write permission in the destination folder
# - Excludes MySQL admin tables ('mysql',information_schema','performance_schema')
#
################################################

##### VARIABLES
# MySQL User
USER='root'
# MySQL Password
PASSWORD='MySQL_ROOT_PASSWORD'
# Backup Directory - WITH TAILING SLASH IF PATH OTHER THEN '.'!
OUTPUT="/home/backups/mysql"
BUCKET="NAME_OF_S3_BUCKET"
 
##### EXECUTE THE DB BACKUP
TIMESTAMP=`date +%Y%m%d_%H`;
OUTPUTDEST=$OUTPUT;
echo "Starting MySQL Backup";
echo `date`;
databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] && [[ "$db" != "mysql" ]] && [[ "$db" != "performance_schema" ]] ; then
        echo "Dumping database: $db"
        mysqldump --single-transaction --routines --triggers --user=$USER --password=$PASSWORD --databases $db > $OUTPUTDEST/dbbackup-$TIMESTAMP-$db.sql
        zstd --rm -q $OUTPUTDEST/dbbackup-$TIMESTAMP-$db.sql
    fi
done
aws --only-show-errors s3 sync $OUTPUTDEST s3://$BUCKET/`date +%Y`/`date +%m`/`date +%d`/
rm -rf /home/backups/mysql/dbbackup-*
echo "Finished MySQL Backup";
echo `date`;
