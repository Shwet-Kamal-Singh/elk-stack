#!/bin/bash

# Set variables
ELASTICSEARCH_HOST="localhost"
ELASTICSEARCH_PORT="9200"
BACKUP_DIR="/path/to/elasticsearch/backup"
REPOSITORY_NAME="es_backup_repo"
SNAPSHOT_NAME="snapshot_$(date +%Y%m%d_%H%M%S)"
ELASTIC_USER="elastic"
ELASTIC_PASSWORD="your_elastic_password"

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR

# Register the backup repository if it doesn't exist
if ! curl -s -X GET "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_snapshot/$REPOSITORY_NAME" -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure | grep -q "$REPOSITORY_NAME"; then
    curl -X PUT "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_snapshot/$REPOSITORY_NAME" -H 'Content-Type: application/json' -d "{
      \"type\": \"fs\",
      \"settings\": {
        \"location\": \"$BACKUP_DIR\"
      }
    }" -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure
fi

# Create a new snapshot
curl -X PUT "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_snapshot/$REPOSITORY_NAME/$SNAPSHOT_NAME?wait_for_completion=true" -H 'Content-Type: application/json' -d '{
  "indices": "*",
  "ignore_unavailable": true,
  "include_global_state": false
}' -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure

# Check if the snapshot was successful
if [ $? -eq 0 ]; then
    echo "Snapshot $SNAPSHOT_NAME created successfully"
else
    echo "Failed to create snapshot $SNAPSHOT_NAME"
    exit 1
fi

# Delete old snapshots (keep last 7 days)
OLD_SNAPSHOTS=$(curl -s -X GET "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_snapshot/$REPOSITORY_NAME/_all" -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure | jq -r '.snapshots[].snapshot' | sort | head -n -7)

for snapshot in $OLD_SNAPSHOTS; do
    curl -X DELETE "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_snapshot/$REPOSITORY_NAME/$snapshot" -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure
    echo "Deleted old snapshot: $snapshot"
done

echo "Backup process completed"