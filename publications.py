import requests
import sys

# Define the Elasticsearch endpoint
endpoint = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:9200"

# Define the index name
index_name = "publications"

# Define the query
query = {
    "size": 10000,
    "query": {
        "term": {
            "pending": True
        }
    },
    "_source": ["id"]
}

# Send the search request to Elasticsearch
response = requests.get(f"{endpoint}/{index_name}/_search", json=query)

# Extract the "id" field from the search results
data = response.json()
ids = [hit["_source"]["id"] for hit in data["hits"]["hits"]]

# Print the "id" field values
for id in ids:
    print(id)
