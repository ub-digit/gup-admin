#!/bin/bash




# delete all persons from the index
echo "Deleting all departments from the index..."

# Elasticsearch query
read -r -d '' QUERY <<-EOF
{
  "query": {
    "match_all": {}
  }
}
EOF
docker compose exec elasticsearch curl localhost:9200/departments/_delete_by_query   -H "Content-Type: application/json"   -d "$QUERY"


# delete all persons from the database
echo "Deleting all departments from the database..."
docker compose exec -it index-manager-db psql -U postgres -d gup_index_manager_dev -c 'TRUNCATE departments;'
