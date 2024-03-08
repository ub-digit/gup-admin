import os
import json
import requests

# Directory path
directory = '../data/person/'

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
