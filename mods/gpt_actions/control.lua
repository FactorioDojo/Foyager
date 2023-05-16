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


function on_init()
	print("on init")
	global.resources = {}
	global.resources.last_index = 0
	global.resources.list = {} -- might be sparse, so the #-operator won't work
	global.resources.map = {}
	global.map_area = {x1=0, y1=0, x2=0, y2=0} -- a bounding box of all charted map chunks

	global.p = {[1]={}} -- player-private data

	global.pathfinding = {}
	global.pathfinding.map = {}

	global.n_clients = 1

end

function rcon_set_waypoints(player_id, waypoints) -- e.g. waypoints= { {0,0}, {3,3}, {42,1337} }
	tmp = {}
	for i = 1, #waypoints do
		tmp[i] = {x=waypoints[i][1], y=waypoints[i][2]}
	end
	global.p[player_id].walking = {idx=1, waypoints=tmp}
end


function rcon_cancel_waypoints(player_id)
	global.p[player_id].walking = nil
end


function rcon_set_mining_target(player_id, name, position)
	local player = game.players[player_id]
	local ent = nil
	
	if name ~= nil and position ~= nil then
		ent = player.surface.find_entity(name, position)
		if ent and ent.minable then
			global.p[player_id].mining = { entity = ent, prototype = ent.prototype }
		
		else
			game.player.print("Entity not found or out of range")
			global.p[player_id].mining = nil
		end
	else
		game.player.print("Name or position undefined")
	end
end

function rcon_stop_mining_target(player_id)
	global.p[player_id].mining = nil
end

function place_entity(entity_name, position, direction)
    -- Get the surface on which to place the entity (assuming the first surface)
    local surface = game.surfaces[1]

    -- Check if the entity can be placed at the specified position
    if surface.can_place_entity{name = entity_name, position = position, direction = direction} then
        -- Place the entity on the surface
        local placed_entity = surface.create_entity{name = entity_name, position = position, direction = direction, force = game.forces.player}

        -- Check if the entity was successfully placed
        if placed_entity then
            -- Notify the player that the entity has been placed
            game.player.print("Successfully placed " .. entity_name)
        else
            -- Notify the player that the entity could not be placed
            game.player.print("Failed to place " .. entity_name)
        end
    else
        -- Notify the player that the entity cannot be placed at the specified position
        game.player.print(entity_name .. " cannot be placed")
    end
end

function rcon_insert_to_inventory(player_id, entity_name, entity_pos, inventory_type, items)
	local player = game.players[player_id]
	local entity = player.surface.find_entity(entity_name, entity_pos)
	if entity == nil then
		complain("cannot insert to inventory of nonexisting entity "..entity_name.." at "..pos_str(entity_pos))
		return
	end

	local inventory = entity.get_inventory(inventory_type)
	if inventory == nil then
		complain("cannot insert to nonexisting inventory of entity "..entity_name.." at "..pos_str(entity_pos))
		return
	end

	local count = 1
	if items.count ~= nil then count=items.count end

	local available_count = player.get_item_count(items)

	if available_count < count then
		game.print("Player doesn't have enough items")
		count = available_count
	end

	if count > 0 then
		local real_n = inventory.insert({name=items, count=count})

		if count ~= real_n then
			complain("tried to insert "..count.."x "..items.name.." but inserted " .. real_n)
		end

		local check_n = player.remove_item({name=items, count=real_n})
		if check_n ~= real_n then
			complain("wtf, tried to take "..real_n.."x "..items.name.." from player #"..player_id.." but only got "..check_n..". Isn't supposed to happen?!")
		end
	end
end
function rcon_remove_from_inventory(player_id, entity_name, entity_pos, inventory_type, items)
	local player = game.players[player_id]
	local entity = player.surface.find_entity(entity_name, entity_pos)
	if entity == nil then
		player.game.print("ERROR ENTITY NOT FOUND")
	end

	local inventory = entity.get_inventory(inventory_type)
	if inventory == nil then
		return
	end

	local count = 1
	if items.count ~= nil then count=items.count end
	local real_n = inventory.remove(items)

	if real_n > 0 then
		local check_n = player.insert({name=items, count=real_n})

		if check_n ~= real_n then
			complain("wtf, couldn't insert "..real_n.."x "..items.." into player #"..player_id..", but only "..check_n..". dropping them :(.")
		end
	end
end

function rcon_whoami(who)
	if client_local_data.whoami == nil then
		client_local_data.whoami = who
		on_whoami()
	end
end

function rcon_start_crafting(player_id, recipe, count)
	local player = game.players[player_id]
	local ret = player.begin_crafting{count=count, recipe=recipe}
	if ret ~= count then
		complain("could not have player "..player.name.." craft "..count.." "..recipe.." (but only "..ret..")")
	end

	for i = 1,count do
		local aid = nil
		if crafting_queue[player_id] == nil then crafting_queue[player_id] = {} end
		table.insert(crafting_queue[player_id], {recipe=recipe, id=aid})
	end
end

function coord(pos)
	return "("..pos.x.."/"..pos.y..")"
end

function distance(a,b)
	local x1
	local y1
	local x2
	local y2

	if a.x ~= nil then x1 = a.x else x1=a[1] end
	if a.y ~= nil then y1 = a.y else y1=a[2] end
	if b.x ~= nil then x2 = b.x else x2=b[1] end
	if b.y ~= nil then y2 = b.y else y2=b[2] end

	return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
end

function on_tick(event)
		
	for idx, player in pairs(game.players) do
		-- if global.p[idx].walking and player.connected then
		if global.p[idx] and player.connected and player.character then -- TODO FIXME
			if global.p[idx].walking then
				local w = global.p[idx].walking
				local pos = player.character.position
				local dest = w.waypoints[w.idx]

				local dx = dest.x - pos.x
				local dy = dest.y - pos.y

				if (math.abs(dx) < 0.3 and math.abs(dy) < 0.3) then
					w.idx = w.idx + 1
					if w.idx > #w.waypoints then
						player.walking_state = {walking=false}
						global.p[idx].walking = nil
						dx = 0
						dy = 0
					else
						dest = w.waypoints[w.idx]
						dx = dest.x - pos.x
						dy = dest.y - pos.y
					end
				end

				if math.abs(dx) > 0.3 then
					if dx < 0 then dx = -1 else dx = 1 end
				else
					dx = 0
				end

				if math.abs(dy) > 0.3 then
					if dy < 0 then dy = -1 else dy = 1 end
				else
					dy = 0
				end

				local direction
				if dx < 0 then
					direction = "west"
				elseif dx == 0 then
					direction = ""
				elseif dx > 0 then
					direction = "east"
				end

				if dy < 0 then
					direction = "north"..direction
				elseif dy == 0 then
					direction = ""..direction
				elseif dy > 0 then
					direction = "south"..direction
				end

				print("waypoint "..w.idx.." of "..#w.waypoints..", pos = "..coord(pos)..", dest = "..coord(dest).. ", dx/dy="..dx.."/"..dy..", dir="..direction)

				if direction ~= "" then
					player.walking_state = {walking=true, direction=defines.direction[direction]}
				end
			end

			if global.p[idx].mining then
				local ent = global.p[idx].mining.entity

				if ent and ent.valid then -- mining complete
					if distance(player.position, ent.position) > 6 then
						player.print("warning: too far too mine oO?")
					end

					-- unfortunately, factorio doesn't offer a "select this entity" function
					-- we need to select stuff depending on the cursor position, which *might*
					-- select something different instead. (e.g., a tree or the player in the way)
					player.update_selected_entity(ent.position)
					local ent2 = player.selected

					if (ent2 == nil) then
						print("wtf, not mining any target")
					elseif (ent.name ~= ent2.name or ent.position.x ~= ent2.position.x or ent.position.y ~= ent2.position.y) then
						if ent2.type == "tree" then
							print("mining: there's a tree in our way. deforesting...") -- HACK
							player.mining_state = { mining=true, position=ent.position }
						else
							print("wtf, not mining the expected target (expected: "..ent.name..", found: "..ent2.name..")")
						end
					else
						player.mining_state = { mining=true, position=ent.position }
					end
				else
					-- the entity to be mined has been deleted, but p[idx].mining is still true.
					-- this means that on_mined_entity() has *not* been called, indicating that something
					-- else has "stolen" what we actually wanted to mine :(
					global.p[idx].mining = nil
				end
			end
		end
	end
end

script.on_init(on_init)
script.on_event(defines.events.on_tick, on_tick)





remote.add_interface("actions", {
	set_waypoints=rcon_set_waypoints,
	cancel_waypoints=rcon_cancel_waypoints,
	set_mining_target=rcon_set_mining_target,
	stop_mining_target=rcon_stop_mining_target,
	place_entity=place_entity,
	start_crafting=rcon_start_crafting,
	insert_to_inventory=rcon_insert_to_inventory,
	remove_from_inventory=rcon_remove_from_inventory,
	debug_mine_selected=rcon_debug_mine_selected,
	whoami=rcon_whoami
})


