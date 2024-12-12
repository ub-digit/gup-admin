#!/bin/bash




# delete all persons from the index
echo "Deleting all persons from the index..."

# Elasticsearch query
read -r -d '' QUERY <<-EOF
{
  "query": {
    "match_all": {}
  }
}
EOF
docker compose exec elasticsearch curl localhost:9200/persons/_delete_by_query   -H "Content-Type: application/json"   -d "$QUERY"
