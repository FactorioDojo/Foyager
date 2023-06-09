require("lib/log_utils")



-- Determines which direction the character should go.
function get_direction(start_position, end_position)
    local angle = math.atan2(end_position.y - start_position.y, start_position.x - end_position.x)

    -- Given a circle representing the angles, it is divided into eight octants representing the cardinal directions.
    local octant = (angle + math.pi) / (2 * math.pi) * 8 + 0.5

    if octant < 1 then
        return defines.direction.east
    elseif octant < 2 then
        return defines.direction.northeast
    elseif octant < 3 then
        return defines.direction.north
    elseif octant < 4 then
        return defines.direction.northwest
    elseif octant < 5 then
        return defines.direction.west
    elseif octant < 6 then
        return defines.direction.southwest
    elseif octant < 7 then
        return defines.direction.south
    else
        return defines.direction.southeast
    end
end

function positions_approximately_equal(a, b)
    return math.abs(a.x - b.x) < 0.25 and math.abs(a.y - b.y) < 0.25
end


-- ASYNC
-- Requests a path when the map is clicked.
function move(position)
	clog("Info: Called move() function")

	    local surface = game.get_surface("nauvis")
	    local character = game.get_player(1).character
	    local position = {x = x, y = y}
	    local collision_mask = {
	      "water-tile",
	      "object-layer",
	      "player-layer",
	      "train-layer",
	      "consider-tile-transitions",
	  }

	    --
	    t = character.bounding_box
		
	    --probable reason for pathing over water is collision masks.
	    --follow this link for collision masks https://wiki.factorio.com/Types/CollisionMask

	    pos = character.position
	    --game.players[1].print(t.left_top.x .. ", " .. t.left_top.y)
	    --game.players[1].print(t.right_bottom.x .. ", " .. t.right_bottom.y)
	    local bbox ={{pos.x - 0.5, pos.y - 0.5},{pos.x + 0.5, pos.y + 0.5}}
	    local bbox2 = {{-0.5,-0.5},{0.5,0.5}}

	    global.path_received = false


	    surface.request_path{
	        bounding_box = bbox2,
	        collision_mask = {"water-tile"},
	        start = character.position,
	        goal = position,
	        force = "player",
	        radius = 3.0,
	        path_resolution_modifier = 0
	    }

	    subscribe_on_tick_event(on_tick_move_event)
end


-- ASYNC
-- Handcraft one or more of a recipe
function craft(count, recipe)
	
    clog("Info: called craft() function")
	local player = game.get_player(1)

    if count <= 0 then
        clog("Error: craft count must be >= 0")
        return false
    end

	-- Set globals
	global.craft_recipe = recipe

	amt = player.begin_crafting{recipe = recipe, count = count}

	global.amount_to_craft = amt

    if amt ~= count then
        clog("Warning: tried to craft " .. count .. " items, but could only craft " .. amt)
        -- return true
    end

    clog("Info: successfully crafted " .. count .. " item")

	script.raise_event(global.ASYNC_EXEC_COMPLETE)

	-- return true
end


-- ASYNC
-- Mine resource
function mine_resource(entity, count)

    clog("Info: called mine_resource() function")
	local player = game.get_player(1)
	

	player.update_selected_entity(entity.position)

	-- Check if the selected entity is a resource
	if player.selected.type ~= "resource" then
		clog("Error: mine_entity(entity) should be called when entity is not a resource.")
	end

	if not player.selected then
		clog("Error: entity not selected")
		return false
	end
	-- Check if we are in reach of this tile
	if not player.can_reach_entity(player.selected) then
		clog("Error: entity not reachable")
		return false
	end

	-- Set globals	
	global.mining_position = entity.position
	global.is_mining_resource = true
	global.resources_left_to_mine = count

	-- Subscribe on_tick
	subscribe_on_tick_event(on_tick_mine_event)
end


-- ASYNC
-- Mine entity 
function mine_entity(entity)

    clog("Info: called mine_entity() function")
	local player = game.get_player(1)
	
	-- Check if the selected entity is a resource
	if player.selected.type == "resource" then
		clog("Error: mine_resource(entity) should be called when entity is a resource.")
	end


	player.update_selected_entity(entity.position)
	if not player.selected then
		clog("Error: entity not selected")
		return false
	end
	-- Check if we are in reach of this tile
	if not player.can_reach_entity(player.selected) then
		clog("Error: entity not reachable")
		return false
	end

	-- Set globals	
	global.mining_position = entity.position
	global.is_mining_entity = true

	-- Subscribe on_tick
	subscribe_on_tick_event(on_tick_mine_event)
end

-- ASYNC
-- Create an entity on the surface. In most cases this is building a structure/item/entity
-- It checks to see if a fast-replace works first.
-- Returns false on failure to prevent advancing state until within reach and/or item is in the inventory
-- The direction doesn't always work as you'd expect for fluids.
--   asms       - once the recipe gets set, the fluid input will always be north, requiring rotation
--   chems      - direction indicates the side where the fluids are input
--   refineries - direction indicates the side where the fluids output
--   pumps      - direction indicates the side where the fluid is input
function build(position, item, direction)

	local p = game.get_player(1)

    clog("Info: called build() function")
	-- Check if we have the item
	if p.get_item_count(item) == 0 then
        clog("Error: not enough items in player inventory to build item")
		-- debug(p, string.format("build: not enough items: %d", state))
		return false
	end

	-- Grenade special stuff (untested in 0.18)
	-- if item == "grenade" then
	-- 	p.update_selected_entity(position)
	-- 	if not p.selected then
	-- 		return false
	-- 	end
	-- 	p.surface.create_entity{name = item, position = p.position, target=p.selected, force="player", speed=0.35}
	-- 	p.remove_item({name = item, count = 1})
	-- 	return true
	-- end

	--Failed attempt to lay bricks. Work-in-progress
	--if item == "stone-brick" then
	--	p.surface.set_tiles({name = item, position = position})
		--canplace = p.can_place_entity{name = "tile", inner_name = item, position = position, force="player"}
		--if canplace then
		--	p.surface.create_entity{name = "tile", inner_name = item, position = position, force="player"}	
		--	return true
		--else
			--debug(p, string.format("build: cannot place: %d", state))
		--	return false
		--end
	--	return true
	--end

	-- Check if we can actually place the item at this tile
	local canplace = p.can_place_entity{name = item, position = position, direction = direction}
	local asm = false

	if canplace then
		canplace = p.surface.can_fast_replace{name = item, position = position, direction = direction, force = "player"}
		if canplace then
			asm = p.surface.create_entity{name = item, position = position, direction = direction, force="player", fast_replace=true, player=p}
			if asm then
				--When fast replace succeeds, it triggers the on_player_mined_entity event for each item replaced.
				--My handler for that event advances state (otherwise the player would "mine" forever). After the build
				--completes, on_tick advances state after doTask() completes through, which is normal state advancement.
				--Therefore state gets advanced twice in most cases. So I decrement state here so the net value of state
				--is incremented by only one.
				--This issue becomes a serious bug with the splitter, since fast replacing with that item is able to trigger
				--two on_player_mined_entity events, thus advancing state yet another time. For now I handle that by making
				--sure splitters replace at most 1 belt...I mine one of the belts first in my task list.
				
				--I have a better answer for this, but it breaks my 0.18.17 run:
				--Using the mining_done variable means I don't increment state in the on_player_mined_item event.
				--It's a better way, which I would want to use in the future. I wonder if it is dependent upon the
				--order events are processed, possibly a race condition (on_tick vs on_player_mined_entity)
				--Hey also, can_fast_replace does not do distance checking, so it could be
				--cheaty here if I were dishonest. (Is this still true in 0.18?)
				-- state = state - 1
			end
		else
			asm = p.surface.create_entity{name = item, position = position, direction = direction, force="player"}
		end
	else
        clog("Error: cannot build entity at this position, position is occupied")
		--debug(p, string.format("build: cannot place: %d", state))
		return false
	end
	if asm then
		p.remove_item({name = item, count = 1})
	end

    clog("Info: successfully built item at position")

	script.raise_event(global.ASYNC_EXEC_COMPLETE)

	return true
end

-- ASYNC
-- Set the recipe of an assembling machine, chemical plant, or oil refinery (anything I'm missing?)
-- Returns false on failure 
-- Items still in the machine not used in the new recipe will be placed in the character's inventory
-- NOTE: There is a bug here. It is possible to set a recipe that is not yet available through
-- completed research. For now, go on the honor system.
function recipe(position, recipe)
	clog("Info: called recipe() function")

	local p = game.get_player(1)

	p.update_selected_entity(position)
	if not p.selected then
		clog("Error: entity not selected")
		return false
	end
	-- Check if we are in reach of this tile
	if not p.can_reach_entity(p.selected) then
		clog("Error: entity not reachable")
		return false
	end
	if recipe == "none" then
		recipe = nil
	end
	local items = p.selected.set_recipe(recipe)
	if items then
		for name, count in pairs(items) do
			p.insert{name=name, count=count}
		end
	end

	clog("Info: successfully set recipe")
	script.raise_event(global.ASYNC_EXEC_COMPLETE)

	return true
end

-- ASYNC
-- Place an item from the character's inventory into an entity's inventory
-- Returns false on failure 
-- It is possible to put 0 items if none are in the character's inventory
function put(position, item, amount, slot)
    clog("Info: Calling put() function")
	local p = game.players[1]
    p.update_selected_entity(position)

	if not p.selected then
        clog("FATAL: This should not happen")
		return false
	end

 	if not p.can_reach_entity(p.selected) then
        clog("Error: entity is not reachable")
 		--debug(p, string.format("put: entity not reachable: %d", state))
 		return false
 	end

	local amountininventory = p.get_item_count(item)
	local otherinv = p.selected.get_inventory(slot)
	local toinsert = math.min(amountininventory, amount)

	if toinsert == 0 then
        clog("Error: cannot insert 0 items")
		-- debug(p, string.format("put: nothing to insert: %d", state))
		return true
	end

	if not otherinv then
        clog("Error: No slot to insert items")
		--debug(p, string.format("put: no slot: %d", state))
		return false
	end

	local inserted = otherinv.insert{name=item, count=toinsert}
	--if we already failed for trying to insert no items, then if no items were inserted, it must be because it is full
	if inserted == 0 then
        clog("Warning: Slot was full, nothing was inserted")
		return false
        -- debug(p, string.format("put: nothing inserted: %d", state))
		-- return true
	end

    clog("Info: successfully  inserted " .. amount .. " items")
	p.remove_item{name=item, count=inserted}

	script.raise_event(global.ASYNC_EXEC_COMPLETE)

	return true
end

-- ASYNC
-- Take an item from the entity's inventory into the character's inventory
-- Returns false on failure
-- It is possible to take 0 items if none are in the entity's inventory
function take(position, item, amount, slot)

	local p = game.get_player(1)

    clog("Info: Calling take() function")
	p.update_selected_entity(position)

	if not p.selected then
		--debug(p, string.format("take: entity not selected: %d", state))
		clog("Error: entity not selected")
		return false
	end

	-- Check if we are in reach of this tile
	if not p.can_reach_entity(p.selected) then
        clog("Error: entity is not reachable")
		--debug(p, string.format("take: entity not reachable: %d", state))
		return false
	end

	local otherinv = p.selected.get_inventory(slot)

	if not otherinv then
		--debug(p, string.format("take: no slot: %d", state))
		return false
	end

	local totake = amount
	local amountintarget = otherinv.get_item_count(item)
	if totake == -1 then totake = amountintarget
	else totake = math.min(amountintarget, amount)
	end

	if amountintarget == 0 then
        clog("Warning: nothing to take")
		-- debug(p, string.format("take: nothing to take: %d", state))
		return true
	end

	local taken = p.insert{name=item, count=totake}

	if taken == 0 then
        clog("Warning: nothing taken")
		-- debug(p, string.format("take: nothing taken: %d", state))
		return true
	end

	otherinv.remove{name=item, count=taken}
    clog("Info: items taken successfully")

	script.raise_event(global.ASYNC_EXEC_COMPLETE)

	return true
end

----------- Functions below are not needed for the current agent to function ------------

-- Adjust the filter of a filter inserter. It might work for other filter things too, though
-- probably not splitters
-- Returns false on failure 
function filter(position, filter, slot)

	local p = game.get_player(1)

	p.update_selected_entity(position)
	if not p.selected then
		debug(p, string.format("filter: entity not selected: %d", state))
		return false
	end
	-- Check if we are in reach of this tile
	if not p.can_reach_entity(p.selected) then
		debug(p, string.format("filter: entity not reachable: %d", state))
	 	return false
	end
	p.selected.set_filter(slot, filter)
	return true
end

-- Manually launch the rocket
-- Returns false on failure 
function launch(position)

	local p = game.get_player(1)

	p.update_selected_entity(position)
	if not p.selected then
		debug(p, string.format("launch: entity not selected: %d", state))
		return false
	end
	-- Check if we are in reach of this tile
	if not p.can_reach_entity(p.selected) then
		debug(p, string.format("launch: entity not reachable: %d", state))
		return false
	end
	return p.selected.launch_rocket()
end

-- Set the inventory slot space on chests (and probably other items, which are untested)
-- Returns false on failure 
function limit(position, limit, slot)

	local p = game.get_player(1)

	p.update_selected_entity(position)
	if not p.selected then
		debug(p, string.format("limit: entity not selected: %d", state))
		return false
	end
	-- Check if we are in reach of this tile
	if not p.can_reach_entity(p.selected) then
		debug(p, string.format("limit: entity not reachable: %d", state))
		return false
	end

	local otherinv = p.selected.get_inventory(slot)

	if not otherinv then
		debug(p, string.format("limit: no slot: %d", state))
		return true
	end

	--hasbar No longer in the API
	--if not otherinv.hasbar() then
	--	debug(p, string.format("limit: entity has no bar: %d", state))
	--	return true
	--end

	-- Setting set_bar to 1 completely limits all slots, so it's off by one
	otherinv.set_bar(limit+1)
	return true
end

-- Set the input/output/filter settings for a splitter
-- Returns false on failure 
function priority(position, input, output, filter)

	local p = game.get_player(1)

	p.update_selected_entity(position)
	if not p.selected then
		debug(p, string.format("priority: entity not selected: %d", state))
		return false
	end
	-- Check if we are in reach of this tile
	if not p.can_reach_entity(p.selected) then
		debug(p, string.format("priority: entity not reachable: %d", state))
	    return false
	end
	p.selected.splitter_input_priority = input
	p.selected.splitter_output_priority = output
	if filter == "none" then
		p.selected.splitter_filter = nil
	else
		p.selected.splitter_filter = filter
	end
	return true
end

-- Rotate an entity one quarter turn
-- Returns false on failure 
function rotate(position, direction)

	local p = game.get_player(1)

	local opts = {reverse = false}
	p.update_selected_entity(position)
	if not p.selected then
		debug(p, string.format("rotate: entity not selected: %d", state))
		return false
	end
	-- Check if we are in reach of this tile
	if not p.can_reach_entity(p.selected) then
		debug(p, string.format("rotate: entity not reachable: %d", state))
	 	return false
	end
	if direction == "ccw" then
		opts = {reverse = true}
	end
	p.selected.rotate(opts)
	-- Not sure this is a good idea. Rotating a belt 180 requires two rotations. But
	-- rotating an underground belt 180 requires only one rotation. So maybe allowing 180
	-- will cause some headaches.
	if direction == "180" then
		p.selected.rotate(opts)
	end
	return true
end

-- Set the gameplay speed. 1 is standard speed
function speed(speed)
	game.speed = speed
	return true
end

-- Set the current research
function tech(p, research)
	p.force.research_queue_enabled = true
	p.force.add_research(research)
	return true
end

-- Bulk move items from the character's inventory into the entity's inventory
-- Returns false on failure 
-- NOTE: This should only be used to transfer items into an empty entity because it
-- simply overwrites the contents of the slots of the entity. For now, go on the honor system.
function transfer(position, numslots, slot)

	local p = game.get_player(1)

	p.update_selected_entity(position)
	if not p.selected then
		debug(p, string.format("transfer: entity not selected: %d", state))
		return false
	end

	if not p.can_reach_entity(p.selected) then
		debug(p, string.format("transfer: entity not reachable: %d", state))
		return false
	end

	local src = p.get_inventory(defines.inventory.character_main)
	local dst = p.selected.get_inventory(slot)
	local i = 1
	while i <= numslots do
		local src_stack = src[i]
		local dst_stack = dst[i]
		if dst_stack.can_set_stack(src_stack) then
			dst_stack.set_stack(src_stack)
			src_stack.clear()
		else
			return true
		end
		i = i + 1
	end
	return true
end

-- Drop items on the ground (like pressing the 'z' key)
function drop(position, item)

	local p = game.get_player(1)

	local canplace = p.can_place_entity{name = item, position = position}
	if canplace then
		p.surface.create_entity{name = "item-on-ground",
								stack = {
									name = item,
									count = 1,
								},
								position = position,
								force = "player",
								spill = true
								}
	end
	return true
end

-- Make a quick blueprint of an area then paste that blueprint in another location
function blueprint(topleft, bottomright, position, direction)
	local p = game.get_player(1)
	p.cursor_stack.set_stack('blueprint')
	p.cursor_stack.create_blueprint{area = {topleft, bottomright},
	                                surface=p.surface, force=p.force}
	p.cursor_stack.build_blueprint{surface=p.surface, force=p.force, position=position, direction=direction}
	p.cursor_stack.clear()
	return true
end