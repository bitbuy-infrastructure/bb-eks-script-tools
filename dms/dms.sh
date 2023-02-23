#!/bin/bash
###
# requeriments: brew install awscli && brew install jq
# config aws credentials for "OLD PROD account"
#	[default] 
#	aws_access_key_id = AKIA4JXxxxxxxxx
#	aws_secret_access_key = XxxxxxxxxxXXXXXXXXXXXXX
###
log_file="log_dms.log"
status="new"
source_endpoint_status="new"
target_endpoint_status="new"
msg='1st parameter needs to be "da" | "qa" | "pd". And 2nd parameter needs to be exactly the database name to be copied.\n
./dms.sh <env> <old_db_name> <optional_new_db_name>\nex: ./dms.sh da staking bitbuy_staking'
function log {
	echo -n "`date -u` | " >> $log_file
	$@ >> $log_file
}
if [ -z $1 ] || [ -z $2 ]; then
	echo -e $msg; exit;
fi
source new_db.sh
if [ -z $new_username ] || [ -z $new_db_name ]; then
	echo "Please setup the new_db.sh file."; exit;
fi
source old_db.sh
if [ -z $old_master_pwd ]; then
	echo "Please setup the old_master_pwd of user "$old_master_user" from db_host: "$old_db_hostname; exit;
fi
if [ -z $new_user_pwd ]; then
	echo "Please setup the new_user_pwd of user "$new_username" from db_host: "$new_db_host; exit;
fi
log echo "### Migrate env "$1" db "$2" ###"
log echo "Creating source endpoint... "
source_endpoint_arn=$(aws dms create-endpoint --endpoint-identifier from-postgres-$1-db-`echo $2 | tr '_' '-'` --endpoint-type source --engine-name postgres \
--username $old_master_user --password $old_master_pwd --server-name $old_db_hostname --port 5432 --database-name $2 | jq -r ."Endpoint"."EndpointArn")
log echo $source_endpoint_arn
log echo "Creating target endpoint... "
target_endpoint_arn=$(aws dms create-endpoint --endpoint-identifier to-aurora-$1-db-`echo $new_db_name | tr '_' '-'` --endpoint-type target --engine-name aurora-postgresql \
--username $new_username --password $new_user_pwd --server-name $new_db_host --port 5432 --database-name $new_db_name | jq -r ."Endpoint"."EndpointArn")
log echo $target_endpoint_arn

aws dms test-connection --replication-instance-arn $rep_instance_arn --endpoint-arn $source_endpoint_arn
aws dms test-connection --replication-instance-arn $rep_instance_arn --endpoint-arn $target_endpoint_arn

while [[ $source_endpoint_status != \"successful\" ]] && [[ $target_endpoint_status != \"successful\" ]] ; do
	source_endpoint_status=$(aws dms describe-connections --filter "Name=endpoint-arn,Values=$source_endpoint_arn" --query "Connections[0].Status")
	target_endpoint_status=$(aws dms describe-connections --filter "Name=endpoint-arn,Values=$source_endpoint_arn" --query "Connections[0].Status")
	echo "Connections: "$source_endpoint_status" and "$target_endpoint_status
	sleep 1
done
aws dms describe-connections --filter "Name=endpoint-arn,Values=$source_endpoint_arn,$target_endpoint_arn"
log echo "Creating replication task..."
aws dms create-replication-task --replication-task-identifier migrate-$1-postgres-db-to-aurora-`echo $2 | tr '_' '-'`-db --source-endpoint-arn $source_endpoint_arn --target-endpoint-arn $target_endpoint_arn \
--replication-instance-arn $rep_instance_arn --migration-type $migration_type --table-mappings file://table-mappings --replication-task-settings file://task-settings
replication_task_arn=$(aws dms describe-replication-tasks --filters "Name= replication-task-id,Values=migrate-$1-postgres-db-to-aurora-`echo $2 | tr '_' '-'`-db" --query "ReplicationTasks[0].ReplicationTaskArn" --output text)
log echo $replication_task_arn

while [[ $status != \"ready\" ]]; do
	status=$(aws dms describe-replication-tasks --filters "Name=replication-task-arn,Values=$replication_task_arn" --query "ReplicationTasks[0].Status")
	if [ $status == \"ready\" ]; then
		log echo "Replication "$status" to start"
		aws dms start-replication-task --replication-task-arn $replication_task_arn --start-replication-task-type start-replication
		log echo "Replication Started!"
	else
		sleep 3
		echo "Current task status: "$status " Waiting for be ready to start-replication-task"
	fi
done

while [[ $status != \"stopped\" ]]; do
	status=$(aws dms describe-replication-tasks --filters "Name=replication-task-arn,Values=$replication_task_arn" --query "ReplicationTasks[0].Status")
	if [ $status == \"stopped\" ]; then
		log echo "Replication "$status" checking if it completed..."
		finish=$(aws dms describe-replication-tasks --filters "Name=replication-task-arn,Values=$replication_task_arn" --query "ReplicationTasks[0].StopReason")
		if [[ \'"$finish"\' == *"FULL_LOAD_ONLY_FINISHED"* ]]; then
			log echo "### Load complete! Migration process completed. Check the tables. Ex: select count(*) from <table_name>; ###"
		else
			log echo "### Replication failed! Reason: "$finish" ###"
		fi
	else
		full_load=$(aws dms describe-replication-tasks --filters "Name=replication-task-arn,Values=$replication_task_arn" --query "ReplicationTasks[0].ReplicationTaskStats.FullLoadFinishDate")
		if [ $status == \"running\" ] && [ $migration_type == 'full-load-and-cdc' ] && [ ! -z $full_load ]; then
			log echo "### Load completed! Replication ongoing! Migration process completed. Check the tables. Ex: select count(*) from <table_name>; ###"
			exit;
		fi
		sleep 3
		echo "Current task status: "$status " Waiting for task get completed"
	fi
done
