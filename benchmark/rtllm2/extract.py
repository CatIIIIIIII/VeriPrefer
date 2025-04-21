# iterate over current directory and get only the first level subdirectories
import os
import sys
import json

data = []
# Get only the first level subdirectories
for item in os.listdir('.'):
    if os.path.isdir(item):
        
        with open(f'{item}/design_description.txt', 'r') as f:
            spec = f.read()
        
        data.append({
            'name': item,
            'spec': spec
        })
            
with open("rtllm2.json", "w") as f:
    json.dump(data, f, indent=4)
