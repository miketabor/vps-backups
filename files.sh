################################################
#
# Backup all files in the nginx home directory.
# NOTES:
# - gzip must be installed on the system
#
################################################

##### VARIABLES
OUTPUT="/home/backups/files"
 
##### EXECUTE THE FILES BACKUP
TIMESTAMP=`date +%Y%m%d_%H`;
OUTPUTDEST=$OUTPUT;
echo "Starting Files Backup";
cd /home/nginx/domains/
tar -czf $OUTPUTDEST/filesbackup-SERVER_HOST_NAME-$TIMESTAMP.tar *
/usr/local/bin/aws --only-show-errors s3 cp $OUTPUTDEST/filesbackup-SERVER_HOST_NAME-$TIMESTAMP.tar s3://AWS_BUCKET_NAME/
rm -f $OUTPUTDEST/filesbackup-*
echo "Finished Files Backup";
echo `date`;
