#!/bin/bash
status=$(aws dms describe-replication-tasks --filters "Name=replication-task-arn,Values=$1" --query "ReplicationTasks[0].Status")
if [[ $status == \"stopped\" ]] && [[ ! -z $status ]]; then
	aws dms stop-replication-task --replication-task-arn $1
fi
while [[ $status != \"stopped\" ]] && [[ ! -z $status ]]; do
	status=$(aws dms describe-replication-tasks --filters "Name=replication-task-arn,Values=$1" --query "ReplicationTasks[0].Status")
	if [[ $status == \"stopped\" ]] && [[ ! -z $status ]]; then
		log echo "Replication "$status""
		aws dms delete-replication-task --replication-task-arn $1
		log echo "Deleting task."
	else
		sleep 3
		echo "Current task status: "$status " Waiting for stopped to delete-replication-task"
	fi
done

if [ $2 ]; then
	aws dms delete-endpoint --endpoint-arn $2
fi
if [ $3 ]; then
	aws dms delete-endpoint --endpoint-arn $3
fi
