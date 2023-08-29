import requests
import sys
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--dir", dest = "dir_path", required = True)
parser.add_argument("-u", "--url", dest = "url", required = True)
parser.add_argument("-a", "--api-key", dest = "api_key", required = True)

args = parser.parse_args()

if not os.path.isdir(args.dir_path):
  print("No directory: " + args.dir_path) 
  sys.exit()

for file_name in os.listdir(args.dir_path):
  with open(os.path.join(args.dir_path, file_name)) as content:
    print("Put file " + file_name)
    response = requests.put(args.url + "/publications/?api_key=" + args.api_key, data = content, headers = {"Content-Type": "application/json"})
    print(response.text)
