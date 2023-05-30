-- MIT License
-- 
-- Copyright (c) 2017, 2018, 2023 Florian Jung, Penguin and Whale
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this factorio lua stub and associated
-- documentation files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use, copy, modify,
-- merge, publish, distribute, sublicense, and/or sell copies of the
-- Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

outfile="output1.txt"
init_out = "init_out.txt"
client_local_data = nil -- DO NOT USE, will cause desyncs
local todo_next_tick = {}


function inventory_type_name(invtype, enttype)
	local burner = {
		[defines.inventory.fuel] = "fuel",
		[defines.inventory.burnt_result] = "burnt_result"
	}

	local chest = {
		[defines.inventory.chest] = "chest"
	}

	local furnace = {
		[defines.inventory.furnace_source] = "furnace_source",
		[defines.inventory.furnace_result] = "furnace_result",
		[defines.inventory.furnace_modules] = "furnace_modules"
	}

	local player = {
		[defines.inventory.character_main] = "character_main",
		[defines.inventory.character_guns] = "character_guns",
		[defines.inventory.character_ammo] = "character_ammo",
		[defines.inventory.character_armor] = "character_armor",
		[defines.inventory.character_vehicle] = "character_vehicle",
		[defines.inventory.character_trash] = "character_trash"
	}

	local god = {
		[defines.inventory.god_main] = "god_main"
	}

	local roboport = {
		[defines.inventory.roboport_robot] = "roboport_robot",
		[defines.inventory.roboport_material] = "roboport_material"
	}

	local robot = {
		[defines.inventory.robot_cargo] = "robot_cargo",
		[defines.inventory.robot_repair] = "robot_repair"
	}

	local machine = {
		[defines.inventory.assembling_machine_input] = "assembling_machine_input",
		[defines.inventory.assembling_machine_output] = "assembling_machine_output",
		[defines.inventory.assembling_machine_modules] = "assembling_machine_modules"
	}

	local lab = {
		[defines.inventory.lab_input] = "lab_input",
		[defines.inventory.lab_modules] = "lab_modules"
	}

	local mining_drill = {
		[defines.inventory.mining_drill_modules] = "mining_drill_modules"
	}

	local item = {
		[defines.inventory.item_main] = "item_main"
	}

	local silo = {
		[defines.inventory.rocket] = "rocket",
		[defines.inventory.rocket_silo_rocket] = "rocket_silo_rocket",
		[defines.inventory.rocket_silo_result] = "rocket_silo_result"
	}

	local car = {
		[defines.inventory.car_trunk] = "car_trunk",
		[defines.inventory.car_ammo] = "car_ammo"
	}

	local wagon = {
		[defines.inventory.cargo_wagon] = "cargo_wagon"
	}

	local turret = {
		[defines.inventory.turret_ammo] = "turret_ammo"
	}

	local beacon = {
		[defines.inventory.beacon_modules] = "beacon_modules"
	}

	local corpse = {
		[defines.inventory.character_corpse] = "character_corpse"
	}

	local map = {
		["player"] = {player},
		["container"] = {chest},
		["locomotive"] = {burner, car},
		["car"] = {burner, car},
		["wagon"] = {wagon, car},
		["robot"] = {robot},
		["roboport"] = {roboport},
		["boiler"] = {burner},
		["reactor"] = {burner},
		["drill"] = {burner,mining_drill,machine},
		["machine"] = {machine,burner},
		["furnace"] = {furnace,burner},
		["lab"] = {lab,burner},
		["silo"] = {silo},
		--["radar"] = {}, -- TODO FIXME
		["turret"] = {turret},
		["?"] = {machine, burner, player}
	}

	local lastpart = enttype:match(".*-\\([^-]*\\)")
	if lastpart == nil then lastpart = enttype end

	local mymap = map[lastpart]
	if mymap == nil then
		mymap = map["?"]
	else
		local offset = #mymap
		for i,x in ipairs(map["?"]) do
			mymap[offset+i] = x
		end
	end
	for _,m in ipairs(mymap) do
		if m[invtype] ~= nil then
			return m[invtype]
		end
	end
end

-- Function to write data to a file
local function write_data_to_file(data)
  local filename = "output.txt" -- Name of the output file
  game.write_file(filename, data) -- Write data to the file
end

<<<<<<< Updated upstream
function writeout_entity_prototypes()
	header = "entity_prototypes: "
	lines = {}
	for name, prot in pairs(game.entity_prototypes) do
		if string.sub(name, 1, 8) ~= "DATA_RAW" then
			local coll = ""
			local mine_result = ""
			if prot.collision_mask ~= nil then
				if prot.collision_mask['player-layer'] then coll=coll.."P" else coll=coll.."p" end
				if prot.collision_mask['object-layer'] then coll=coll.."O" else coll=coll.."o" end
			end
			if prot.mineable_properties.minable then
				mine_result = ""
				local array = {}
				if (prot.mineable_properties.products == nil) then
					print("wtf, entity "..name.." is mineable, but has no products?!")
				else
					for itemname,amount in pairs(products_to_dict(prot.mineable_properties.products)) do
						table.insert(array, itemname..":"..amount)
					end
				end
				mine_result = table.concat(array, ",")
			else
				mine_result = "-"
			end
			table.insert(lines, prot.name.." "..prot.type.." "..coll.." "..aabb_str(prot.collision_box).." "..mine_result)
		end
	end
	write_init_file(0, header..table.concat(lines, "$").."\n")
=======
-- writeout functions to read data
function writeout_initial_stuff()
	writeout_entity_prototypes()
	writeout_recipes()

end

function WriteOutResources()
    -- Define the area to scan for resources (e.g., a square with corners at (-100, -100) and (100, 100))
    local area = {{-100, -100}, {100, 100}}

    -- Create a table to store the resource data
    local resource_data = {}

    -- Find all resource entities in the defined area
    local resources = game.surfaces[1].find_entities_filtered({type = "resource", area = area})

    -- Iterate through the resource entities and record their positions and types
    for _, resource in ipairs(resources) do
        local position = resource.position
        local resource_type = resource.name
        table.insert(resource_data, {resource_type = resource_type, position = position})
    end

    -- Convert the resource data to JSON format
    local json_data = game.table_to_json(resource_data)

    -- Write the JSON data to a file
    local filename = "resource_data.json"
    game.write_file(filename, json_data, false)

    -- Notify the player that the resource data has been written
    game.player.print("Resource data has been written to " .. filename)
end
function writeout_filtered_entities(entity_type)
    local player_id = 1  -- Specify the ID of the player whose position you want to get
    local player = game.players[player_id]  -- Get the player instance using the player's ID
    local player_position = player.character.position

    local surface = game.surfaces['nauvis']
    local chunk_x = player_position.x -  100
    local chunk_y = player_position.y - 100
    local chunk_xend = player_position.x + 100
    local chunk_yend = player_position.y + 100

    local area={left_top={x=chunk_x, y=chunk_y}, right_bottom={x=chunk_xend, y=chunk_yend}}

    -- Create a table to store the entity data
    local entity_data = {}

    -- Find all entities in the defined area of the specified type
    local entities = surface.find_entities_filtered({area = area, type = entity_type})

    -- Iterate through the entities and record their positions and types
    for _, entity in ipairs(entities) do
        local position = entity.position
        local entity_type = entity.name
        table.insert(entity_data, {entity_type = entity_type, position = position})
    end

    -- Convert the entity data to JSON format
    local json_data = game.table_to_json(entity_data)

    -- Write the JSON data to a file
    local filename = entity_type .. "_data.json"
    game.write_file(filename, json_data, false)

    -- Notify the player that the entity data has been written
    game.player.print("Entity data has been written to " .. filename)
>>>>>>> Stashed changes
end


function writeout_recipes()
	-- FIXME: this assumes that there is only one player force
	header = "recipes: "
	lines = {}
	for name, rec in pairs(game.forces["player"].recipes) do
		ingredients = {}
		products = {}
		for _,ing in ipairs(rec.ingredients) do
			table.insert(ingredients, ing.name.."*"..ing.amount)
		end

		for _,prod in ipairs(rec.products) do
			table.insert(products, prod.name.."*"..simplify_amount(prod))
		end

		table.insert(lines, rec.name.." "..(rec.enabled and "1" or "0").." "..rec.energy.." "..table.concat(ingredients,",").." "..table.concat(products,","))
	end
	write_file(0,header..table.concat(lines, "$").."\n")
end

function writeout_tiles(surface, area) -- SLOW! beastie can do ~2.8 per tick
	--if my_client_id ~= 1 then return end
	local header = "tiles "..area.left_top.x..","..area.left_top.y..";"..area.right_bottom.x..","..area.right_bottom.y..": "
	
	local tile = nil
	local line = {}
	for y = area.left_top.y, area.right_bottom.y-1 do
		for x = area.left_top.x, area.right_bottom.x-1  do
			tile = surface.get_tile(x,y)
			table.insert(line, tile.collides_with('player-layer') and "1" or "0")
		end
	end
	
	local json_data = game.table_to_json(line)

    -- Write the JSON data to a file
    local filename = "tiles.json"
    game.write_file(filename, json_data, false)
end

function writeout_resources(surface, area) -- quite fast. beastie can do > 40, up to 75 per tick
	--if my_client_id ~= 1 then return end
	header = "resources "..area.left_top.x..","..area.left_top.y..";"..area.right_bottom.x..","..area.right_bottom.y..": "
	line = ''
	lines={}
	for idx, ent in pairs(surface.find_entities_filtered{area=area, type='resource'}) do
		line=line..","..ent.name.." "..ent.position.x.." "..ent.position.y
		if idx % 100 == 0 then
			table.insert(lines,line)
			line=''
		end
	end
	table.insert(lines,line)
	write_file(header..table.concat(lines,"").."\n")

	line=nil
end

function writeout_filtered_entities(entity_type)
    -- ...

    -- Iterate through the entities and record their positions, types, and contents
    for _, entity in ipairs(entities) do
        local position = entity.position
        local entity_type = entity.name
        local contents = nil

        -- If the entity has an inventory, get its contents
        if entity.get_inventory(defines.inventory.chest) then
            contents = entity.get_inventory(defines.inventory.chest).get_contents()
        end

        -- If the entity is a transport belt, get its contents
        if entity.type == "transport-belt" then
            contents = entity.get_transport_line(1).get_contents()  -- get contents of the first transport line
            for item, count in pairs(entity.get_transport_line(2).get_contents()) do  -- get contents of the second transport line
                if contents[item] then
                    contents[item] = contents[item] + count
                else
                    contents[item] = count
                end
            end
        end

        table.insert(entity_data, {entity_type = entity_type, position = position, contents = contents})
    end

    -- ...
end


function writeout_item_containers(tick, surface)
	header = "item_containers: " -- fixme: only writeout per area
	line = ''
	lines={}
	
	local i=defines.inventory
	local inventory_types = { 1,2,3,4,5,6,7,8 } -- FIXME HACK

	-- TODO FIXME this is inefficient as hell
	for idx, ent in pairs(surface.find_entities()) do
		--if area.left_top.x <= ent.position.x and ent.position.x < area.right_bottom.x and area.left_top.y <= ent.position.y and ent.position.y < area.right_bottom.y then
		if ent.name ~= "player" then
			local has_inventory = false

			local inventory_strings = {}

			for _,inventory_type in ipairs(inventory_types) do
				local inv = ent.get_inventory(inventory_type)
				if inv ~= nil then
					has_inventory = true
					local inventory_content = {}
					for item,amount in pairs(inv.get_contents()) do
						table.insert(inventory_content, item..":"..amount)
					end
					table.insert(inventory_strings, inventory_type_name(inventory_type, ent.type).."="..table.concat(inventory_content, "%"))
				end
			end

			if has_inventory then
				line=line..","..ent.name.." "..ent.position.x.." "..ent.position.y.." "..table.concat(inventory_strings,"+")

				if idx % 100 == 0 then
					table.insert(lines,line)
					line=''
				end
			end
		end
	end
	table.insert(lines,line)
	write_file(tick, header..table.concat(lines,"").."\n")

	line=nil
end

function writeout_objects(tick, surface, area)
	--if my_client_id ~= 1 then return end
	header = "objects "..area.left_top.x..","..area.left_top.y..";"..area.right_bottom.x..","..area.right_bottom.y..": "
	line = ''
	lines={}
	for idx, ent in pairs(surface.find_entities(area)) do
		if area.left_top.x <= ent.position.x and ent.position.x < area.right_bottom.x and area.left_top.y <= ent.position.y and ent.position.y < area.right_bottom.y then
			if ent.prototype.collision_mask ~= nil and (ent.prototype.collision_mask['player-layer'] or ent.prototype.collision_mask['object-layer']) then
				local dir
				if ent.type == "pipe" or ent.type == "wall" or ent.type == "heat-pipe" then
					-- HACK to render pipes/walls etc correctly *most* of the time. (at least for straight parts)
					-- this requires writeout_objects of neighboring entities whenever a pipe/wall etc is placed, because adjacent things might change their
					-- direction as well
					local n_horiz = 0
					local n_vert = 0
					n_horiz = n_horiz + #surface.find_entities_filtered{type=ent.type, position={x=ent.position.x+1, y=ent.position.y}}
					n_horiz = n_horiz + #surface.find_entities_filtered{type=ent.type, position={x=ent.position.x-1, y=ent.position.y}}
					n_horiz = n_horiz + #surface.find_entities_filtered{type=ent.type.."-to-ground", position={x=ent.position.x+1, y=ent.position.y}}
					n_horiz = n_horiz + #surface.find_entities_filtered{type=ent.type.."-to-ground", position={x=ent.position.x-1, y=ent.position.y}}
					n_vert  = n_vert  + #surface.find_entities_filtered{type=ent.type, position={x=ent.position.x, y=ent.position.y+1}}
					n_vert  = n_vert  + #surface.find_entities_filtered{type=ent.type, position={x=ent.position.x, y=ent.position.y-1}}
					n_vert  = n_vert  + #surface.find_entities_filtered{type=ent.type.."-to-ground", position={x=ent.position.x, y=ent.position.y+1}}
					n_vert  = n_vert  + #surface.find_entities_filtered{type=ent.type.."-to-ground", position={x=ent.position.x, y=ent.position.y-1}}

					if n_horiz > n_vert then
						dir = defines.direction.east
					else
						dir = defines.direction.north
					end
				else
					dir = ent.direction
				end

				line=line..","..ent.name.." "..ent.position.x.." "..ent.position.y.." "..direction_str(dir)
				if idx % 100 == 0 then
					table.insert(lines,line)
					line=''
				end
			end
		end
	end
	table.insert(lines,line)
	write_file(tick, header..table.concat(lines,"").."\n")

	line=nil
end

function products_to_dict(products) -- input: array of products, output: dict["item"] = amount
	local result = {}
	for _,product in ipairs(products) do
		if product.amount then
			result[product.name] = (result[product.name] or 0) + product.amount
		end
	end
	return result
end

function aabb_str(aabb)
	return pos_str(aabb.left_top) .. ";" .. pos_str(aabb.right_bottom)
end

function pos_str(pos)
	if #pos ~= 2 then
		return pos.x .. "," .. pos.y
	else
		return pos[1] .. "," .. pos[2]
	end
end

function simplify_amount(prod)
	if prod.amount ~= nil then
		return prod.amount
	else
		return (prod.amount_min + prod.amount_max) / 2 * prod.probability
	end
end

function direction_str(d)
	if d == defines.direction.north then
		return "N"
	elseif d == defines.direction.east then
		return "E"
	elseif d == defines.direction.south then
		return "S"
	elseif d == defines.direction.west then
		return "W"
	else
		return "X"
	end
end

function write_file(tick, data, donotupdate)
	if must_write_initstuff then
		must_write_initstuff = false
		writeout_initial_stuff()
	end

	game.write_file(outfile, tick.." "..data, true)
	if donotupdate ~= true then
		last_tick_in_file = tick
	end
end

function write_init_file(tick, data, donotupdate)
	if must_write_initstuff then
		must_write_initstuff = false
		writeout_initial_stuff()
	end

	game.write_file(init_out, tick.." "..data, true)
	if donotupdate ~= true then
		last_tick_in_file = tick
	end
end



function coord(pos)
	return "("..pos.x.."/"..pos.y..")"
end

function WriteOutInventory()
    -- Get the player's main inventory
    local player_inventory = game.player.get_main_inventory()

    -- Create a table to store the inventory data
    local inventory_data = {}

    -- Iterate through the player's inventory and record item names and quantities
    for name, count in pairs(player_inventory.get_contents()) do
        table.insert(inventory_data, {item_name = name, item_count = count})
    end

    -- Convert the inventory data to JSON format
    local json_data = game.table_to_json(inventory_data)

    -- Write the JSON data to a file
    local filename = "inventory_data.json"
    game.write_file(filename, json_data, false)

    -- Notify the player that the inventory data has been written
    game.player.print("Inventory data has been written to " .. filename)
end


function writeout_filtered_entities(entity_type)
	local player_id = 1  -- Specify the ID of the player whose position you want to get
    local player = game.players[player_id]  -- Get the player instance using the player's ID
    local player_position = player.character.position

    local surface = game.surfaces['nauvis']
    local chunk_x = player_position.x -  100
    local chunk_y = player_position.y - 100
    local chunk_xend = player_position.x + 100
    local chunk_yend = player_position.y + 100

    local area={left_top={x=chunk_x, y=chunk_y}, right_bottom={x=chunk_xend, y=chunk_yend}}

    -- Create a table to store the entity data
    local entity_data = {}

    -- Find all entities in the defined area of the specified type
    local entities = surface.find_entities_filtered({area = area, type = entity_type})
    for _, entity in ipairs(entities) do
        local position = entity.position
        local entity_type = entity.name
        local contents = nil

        -- If the entity has an inventory, get its contents
        if entity.get_inventory(defines.inventory.chest) then
            contents = entity.get_inventory(defines.inventory.chest).get_contents()
        end

        -- If the entity is a transport belt, get its contents
        if entity.type == "transport-belt" then
            contents = entity.get_transport_line(1).get_contents()  -- get contents of the first transport line
            for item, count in pairs(entity.get_transport_line(2).get_contents()) do  -- get contents of the second transport line
                if contents[item] then
                    contents[item] = contents[item] + count
                else
                    contents[item] = count
                end
            end
        end

        table.insert(entity_data, {entity_type = entity_type, position = position, contents = contents})
    end

       -- Convert the inventory data to JSON format
	   local json_data = game.table_to_json(entity_data)

	   -- Write the JSON data to a file
	   local filename = entity_type .. "_data.json"
	   game.write_file(filename, json_data, false)
   
	   -- Notify the player that the inventory data has been written
	   game.player.print("Inventory data has been written to " .. filename)
end

-- Define a remote interface to expose the functions
remote.add_interface("writeouts", {
	writeout_filtered_entities=writeout_filtered_entities,
	writeout_inventory = WriteOutInventory,
  })


