# Factorio-Bot-Mods

Mods to interact with an agent in factorio. 

Trimed down and modified version of https://github.com/Windfisch/factorio-bot

# Writeouts

The interface to get game state has the following functions
- writeout_filtered_entities - Writeout all entities of the type passed to a file <entity_type>_data.json

/c remote.call('writeouts', 'writeout_filtered_entities', entity_type) 
ex/
/c remote.call('writeouts', 'writeout_filtered_entities', 'resource') 

/c remote.call('writeouts', 'writeout_filtered_entities', 'transport-belt') 




- writeout_inventory
/c remote.call('writeouts', 'writeout_inventory') 


chatgpt generated potentially dubious list of entity types
"resource": This includes entities like iron ore, copper ore, coal, stone, uranium ore, crude oil, etc.

"tree": There are many different types of trees in Factorio.

"simple-entity": This includes things like rocks, fish, and decorative items.

"player": Represents a player character.

"car": This includes cars and tanks.

"locomotive": Represents the engine part of a train.

"cargo-wagon" and "fluid-wagon": These are the parts of a train that carry items and fluids, respectively.

"lab": Where research is done in the game.

"assembling-machine": This includes entities like assembly machines, oil refineries, and chemical plants.

"furnace": Includes stone, steel, and electric furnaces.

"roboport": The base for logistic and construction robots.

"combat-robot": Includes defender, distractor, and destroyer capsules.

"logistic-robot" and "construction-robot": The two types of robots that operate out of roboports.

"container": Includes wooden, iron, steel, and logistic chests.

"electric-pole": Includes small, medium, and large electric poles, and substations.

"solar-panel" and "accumulator": Parts of the electric network.

"inserter": Includes all types of inserters.

"transport-belt": Includes transport belts, fast transport belts, and express transport belts.

"straight-rail" and "curved-rail": Parts of the railway system.

"gate": A gate that opens to let the player and vehicles through.

"wall": A defensive wall.

"turret": Includes gun turrets, laser turrets, and flamethrower turrets.

"rocket-silo": Where rockets are launched from.
