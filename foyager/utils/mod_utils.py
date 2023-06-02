
BASE = "/opt/factorio/script-output/"
RESOURCES = "/opt/factorio/script-output/resource_data.json"


from sklearn.cluster import MeanShift
import pandas as pd
from collections import defaultdict
import numpy as np
import json


import json

def format_resource_json(data):
    result = {}
    
    for item in data:
        resource_name = item.split('-')[0].strip()
        resource_data = data[item]
        formatted_data = ""
        
        for entry in resource_data:
            count = entry['count']
            bounding_box = entry['bounding_box']
            min_x = bounding_box['min']['x']
            min_y = bounding_box['min']['y']
            max_x = bounding_box['max']['x']
            max_y = bounding_box['max']['y']
            
            formatted_data += f"Count: {count}\n"
            formatted_data += f"Bounding Box:\n"
            formatted_data += f"  Min: ({min_x}, {min_y})\n"
            formatted_data += f"  Max: ({max_x}, {max_y})\n"
        
        result[resource_name] = formatted_data
    
    return result

def resource_clustering():
    # Group entities by type
    try:
        with open(RESOURCES) as f:
            data =  list(json.load(f))
            print(f"RESOURCES:{data}")
            resource_type = defaultdict(list)
            for entity in data:
                resource_type[entity['entity_type']].append(entity['position'])
            
            # Calculate bounding box for each entity type
            result = {}
            for resource, positions in resource_type.items():
                df = pd.DataFrame(positions)
                
                # Perform Mean Shift clustering
                ms = MeanShift()
                clusters = ms.fit_predict(df)
                
                # Calculate bounding box for each cluster
                result[resource] = []
                for cluster_id in np.unique(clusters):
                    cluster_positions = df[clusters == cluster_id]
                    min_x = cluster_positions['x'].min()
                    max_x = cluster_positions['x'].max()
                    min_y = cluster_positions['y'].min()
                    max_y = cluster_positions['y'].max()
                    
                    result[resource].append({
                        'count': len(cluster_positions),
                        'bounding_box': {
                            'min': {'x': min_x, 'y': min_y},
                            'max': {'x': max_x, 'y': max_y},
                        }
                    })
            
            return format_resource_json(result)
    except EnvironmentError: # parent of IOError, OSError *and* WindowsError where available
        print("Failed to read Writeouts from game")


def parse_recipes():
    try:
        with open(BASE+'/recipes.json') as f:
            data =  list(json.load(f))
            # Construct a new dictionary
            recipes = {}
            for item in data:
                recipe_name = item['recipe_name']
                ingredients = {ing['ingredient_name']: ing['ingredient_amount'] for ing in item['ingredients']}
                recipes[recipe_name] = ingredients

            return(recipes)
    except EnvironmentError: # parent of IOError, OSError *and* WindowsError where available
        print("Failed to read recipe writeout from game")    

def parse_inventory():
    try:
        with open(BASE+'/inventory_data.json') as f:
            data =  list(json.load(f))

            # Construct a new dictionary
            items = {}
            for item in data:
                item_name = item['item_name']
                item_count = item['item_count']
                items[item_name] = item_count

            return(items)
    except EnvironmentError: # parent of IOError, OSError *and* WindowsError where available
        print("Failed to read inventory writeout from game")  

    
def process_simple_entity():
    try:
        with open(BASE+'/simple-entity.json') as f:
            data =  list(json.load(f))
    except EnvironmentError: # parent of IOError, OSError *and* WindowsError where available
        print("Failed to read Writeouts from game")

    

# read in the entities from entity type list
def process_filtered_entity(entity: str):
    try:
        with open(f"{BASE}/{entity}_data.json") as data:
            return json.load(data)
    except EnvironmentError: # parent of IOError, OSError *and* WindowsError where available
        print("Failed to read Writeouts from game")

