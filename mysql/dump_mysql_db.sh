#!/bin/bash
 
# need to dump these databases one at a time...
 
# information_schema | 
# hopenhagen         | 
# mysql 
 
# doing them all at once is too intensive
#mysqldump -h localhost -u root -pMagento --opt blueprint_db > /mysql_bkup/bp-prd-01.bp.sql.dmp

mysqldump --single-transaction=TRUE blueprint_db | gzip -c > /root/bpf_magento.dmp.sql.gz
