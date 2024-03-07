import os
import json
import requests
# import os
# import json
# from elasticsearch import Elasticsearch

# # Elasticsearch connection settings
# es = Elasticsearch(hosts=[{'host': 'localhost', 'port': 9200, 'scheme': 'http'}])

# # Directory path
# directory = '../../data/person/'

# # Index name
# index_name = 'persons'

# # Iterate over files in the directory
# for filename in os.listdir(directory):
#     if filename.endswith('.json'):
#         file_path = os.path.join(directory, filename)
#         with open(file_path, 'r') as file:
#             # Read JSON data from file
#             data = json.load(file)
#             # Index the data into Elasticsearch
#             es.index(index=index_name, body=data)


# Directory path
directory = '../../data/person/'

# API endpoint
endpoint = 'http://localhost:4010/persons?api_key=megasecretimpossibletoguesskey'

# API key
api_key = 'megasecretimpossibletoguesskey'

# Iterate over files in the directory
for filename in os.listdir(directory):
    if filename.endswith('.json'):
        file_path = os.path.join(directory, filename)
        with open(file_path, 'r') as file:
            # Read JSON data from file
            data = json.load(file)
            # Send the data to the API endpoint with API key
            response = requests.put(endpoint, json=data)
            # Check the response status
            if response.status_code == 200:
                print(f"Data from {filename} successfully sent to {endpoint}")
            else:
                print(f"Failed to send data from {filename} to {endpoint}. Status code: {response.status_code}")
