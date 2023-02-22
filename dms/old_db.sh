#!/bin/bash
# DA - TEOD
if [ $1 == 'da' ]; then
	old_db_hostname='bmiexchange-da.ckoxusslpepg.us-east-2.rds.amazonaws.com'
	old_master_user='postgres'
	replication_instance='dms-replication-instance-da'
	rep_instance_arn='arn:aws:dms:us-east-2:845571256488:rep:V5IN2O5ZP6AIL2M7IPLZBY3266M3EXJFZGLZIJY'
	migration_type='full-load'
# QA - Stading
elif [ $1 == 'qa' ]; then
	old_db_hostname='bmiexchange-qa.ckoxusslpepg.us-east-2.rds.amazonaws.com'
	old_master_user='bmiexchange'
	replication_instance='dms-replication-instance-qa'
	rep_instance_arn='arn:aws:dms:us-east-2:845571256488:rep:YGG6OCKVWMZ3O7KGNTTTRAKLUFAKLVJJDUZAGEQ'
	migration_type='full-load-and-cdc'
# Production
elif [ $1 == 'pd' ]; then
	old_db_hostname='bmiexchange-prod2.ckoxusslpepg.us-east-2.rds.amazonaws.com'
	old_master_user='postgres'
	replication_instance='dms-replication-instance-prod-to-aurora-cluster'
	rep_instance_arn='arn:aws:dms:us-east-2:845571256488:rep:BKHH3BOLGUEW7Q3PNUI27FRNVCYKD4GNEED5EWI'
	migration_type='full-load-and-cdc'
else
	echo -e $msg; exit;
fi