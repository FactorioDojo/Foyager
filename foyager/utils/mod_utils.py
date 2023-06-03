
BASE = "/opt/factorio/script-output/"
RESOURCES = "/opt/factorio/script-output/resource_data.json"
from luaparser import ast
from luaparser.astnodes import *
from sklearn.cluster import MeanShift
import pandas as pd
from collections import defaultdict
import numpy as np
import json
import re

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


def lua_code_verifier(lua_code, restricted_keywords):
    # Search the Lua code for the restrictions
    for keyword in restricted_keywords:
        if re.search(lua_code, keyword):
            print(f"Restricted keyword or function used")
            return False

    return True
message = '''
****Action Agent ai message****
Explain: N/A

Plan:
1) Craft a burner mining drill using the craft function.
2) Move to a location near the iron ore deposit.
3) Build the burner mining drill at the location.
4) Take the burner mining drill from the inventory and place it on the ground.
5) Start the mining drill by inserting fuel into it.
6) Move to the coal deposit and mine some coal.
7) Put the coal into the mining drill to start mining iron ore.
8) Wait for the mining drill to finish mining the iron ore.
9) Take the iron ore from the mining drill and put it into the inventory.

Function name: gather_resources

Lua code:
```
local function gather_resources()
    -- Craft a burner mining drill
    await craft(1, 'burner-mining-drill')
    player.print("Crafted a burner mining drill")

    -- Move to a location near the iron ore deposit
    await move(-100, 0)
    player.print("Moved to the iron ore deposit")

    -- Build the burner mining drill at the location
    await build(player, {x=-100, y=0}, 'burner-mining-drill', defines.direction.north)
    player.print("Built the burner mining drill")

    -- Take the burner mining drill from the inventory and place it on the ground
    await take(player, {x=-100, y=0}, 'burner-mining-drill', 1, defines.inventory.player_main)
    player.print("Took the burner mining drill from the inventory")

    -- Start the mining drill by inserting fuel into it
    await put({x=-100, y=0}, 'coal', 1, defines.inventory.fuel)
    player.print("Inserted coal into the mining drill")

    -- Move to the coal deposit and mine some coal
    await move(-100, 50)
    player.print("Moved to the coal deposit")

    -- Take the coal from the deposit and put it into the inventory
    await take(player, {x=-100, y=50}, 'coal', 1, defines.inventory.player_main)
    player.print("Took coal from the deposit")

    -- Put the coal into the mining drill to start mining iron ore
    await put({x=-100, y=0}, 'coal', 1, defines.inventory.fuel)
    player.print("Inserted coal into the mining drill to start mining iron ore")

    -- Wait for the mining drill to finish mining the iron ore
    sleep(10)
    player.print("Mining drill finished mining iron ore")

    -- Take the iron ore from the mining drill and put it into the inventory
    await take({x=-100, y=0}, 'iron-ore', 1, defines.inventory.player_main)
    player.print("Took iron ore from the mining drill")
end
```
'''
RESTRICTED_KEYWORDS = ['script.on_event', 'raise_event']

code_pattern = re.compile(r"Lua code:\n```(.*?)```", re.DOTALL)
function_pattern = re.compile(r"local function (.*?)\(\)", re.DOTALL)

code = code_pattern.findall(message)
function = function_pattern.findall(message)
assert (
    code is not None
), "No code found."
assert(lua_code_verifier(code[0], RESTRICTED_KEYWORDS)), "Invalid lua code"
print({
    "program_code": code[0],
    "program_name": function[0],
})
