#!/bin/bash  -

#DESC
#backup file web / html dan mysql Daily

#VAR
WEBREAL="/var/www/real.net"
WEBMRP="/var/www/mrp.real.net"
DEST="/data/backups/daily"
DATE=$(date +%Y%m%d%H%M)
SQLREAL="real"
SQLMRP="mrp"

#CHECKDIR
if [ -d $DEST ]; then echo ""; else mkdir -p $DEST; fi

#BACKUP
/usr/bin/mysqldump --single-transaction=TRUE --routines --all-databases | gzip -c > $DEST/$DATE-all.sql.gz
/usr/bin/mysqldump --single-transaction=TRUE --routines $SQLREAL | gzip -c > $DEST/$DATE-$SQLREAL.sql.gz
/usr/bin/mysqldump --single-transaction=TRUE --routines $SQLMRP | gzip -c > $DEST/$DATE-$SQLMRP.sql.gz
tar czf $DEST/$DATE-real.tgz $WEBREAL
tar czf $DEST/$DATE-mrp.tgz $WEBMRP

#CLEAN
find $DEST -mtime +6 -type f -delete
##########################################################
