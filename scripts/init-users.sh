#!/bin/bash

# Set variables
ELASTICSEARCH_HOST="localhost"
ELASTICSEARCH_PORT="9200"
ELASTIC_USER="elastic"
ELASTIC_PASSWORD="your_elastic_password"

# Function to create a user
create_user() {
    local username=$1
    local password=$2
    local roles=$3
    
    curl -X POST "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_security/user/$username" \
         -H 'Content-Type: application/json' \
         -d "{
           \"password\" : \"$password\",
           \"roles\" : [ $roles ],
           \"full_name\" : \"$username\"
         }" \
         -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure
    
    echo "User $username created"
}

# Function to create a role
create_role() {
    local rolename=$1
    local privileges=$2
    
    curl -X POST "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_security/role/$rolename" \
         -H 'Content-Type: application/json' \
         -d "$privileges" \
         -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure
    
    echo "Role $rolename created"
}

# Wait for Elasticsearch to be ready
until curl -s "https://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT" -u "$ELASTIC_USER:$ELASTIC_PASSWORD" --insecure; do
    echo "Waiting for Elasticsearch..."
    sleep 5
done

echo "Elasticsearch is up. Initializing users and roles..."

# Create roles
create_role "read_only" '{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": ["*"],
      "privileges": ["read", "view_index_metadata"]
    }
  ]
}'

create_role "write_logs" '{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": ["logs-*"],
      "privileges": ["write", "create_index"]
    }
  ]
}'

# Create users
create_user "kibana_user" "kibana_password" "\"kibana_user\", \"read_only\""
create_user "logstash_internal" "logstash_password" "\"logstash_system\", \"write_logs\""
create_user "beats_internal" "beats_password" "\"beats_system\", \"write_logs\""

echo "User and role initialization completed"