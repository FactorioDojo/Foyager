require("util")
require("lib/log_utils")
scripts = require("scripts")
writeouts = require("writeouts")
actions = require("actions")



-- Table of subscriber functions
on_tick_subscribers = {}


function init()

	-- Global variables for the move function
	global.path_received = false 
	global.move_path = {}
	global.move_path_index = 1
	global.character_is_moving = false

    -- Global variables for the craft function
    global.craft_recipe = nil
    global.amount_to_craft = 0
    global.amount_crafted = 0

    -- Global variables for mine function
    global.mining_position = nil
    global.is_mining_entity = false
    global.is_mining_resource = false
    global.resources_mined = 0
    global.resources_left_to_mine = 0


    ------------ ASYNC Execution ------------

	-- Events and event ptrs
	global.event_ptrs = {}
	global.events = {}
	global.current_event_ptr = nil

	-- Create a custom event for successfully finished tasks 
    -- Not actually used for anything
	global.SCRIPT_SUCCESS_EVENT = script.generate_event_name() 
	
    -- Create a custom event for tasks that failed
	global.SCRIPT_FAILED_EVENT = script.generate_event_name()
	
    -- Create a custom event for executing a script 
    -- Starts the task process 
	global.SCRIPT_EXECUTED_EVENT = script.generate_event_name()
    
    -- Create a custom event for finishing an async function
    -- Raised upon any async-type function completing execution.
    -- This includes runtime scripts
    global.ASYNC_EXEC_COMPLETE = script.generate_event_name()

    

    -- Script execution. Prime the event ptr.
    script.on_event(global.SCRIPT_EXECUTED_EVENT, function(event)
        -- Set event_ptr
        global.current_event_ptr = event.function_name
    end)

    -- Async execution
    script.on_event(global.ASYNC_EXEC_COMPLETE, function(event)
        -- Find the next event_ptr
        local next_event_ptr = global.event_ptr[global.current_event_ptr]
        -- Does it exist?
        if next_event_ptr ~= nil then
            -- Locate the event
            local next_event = global.events[next_event_ptr]
            -- Set the current event ptr
            global.current_event_ptr = next_event_ptr
            -- Fire event
            script.raise_event(next_event)
        else
            global.current_event_ptr = nil
        end
    end)

end


commands.add_command("init", nil, function(command)
    init()
    global.message_id = 1
    clog("Info: Mod init successful")
end)



-- Event subscribers
function subscribe_on_tick_event(func)
    table.insert(on_tick_subscribers, func)
end

function unsubscribe_on_tick_event(func)
    for i, subscriber in ipairs(on_tick_subscribers) do
        if subscriber == func then
            table.remove(on_tick_subscribers, i)
            break
        end
    end
end

------------ Movement ------------

-- Moves the character.
on_tick_move_event = function(event)
    local character = game.get_player(1).character
    if global.character_is_moving and global.move_path ~= nil then
        if positions_approximately_equal(character.position, global.move_path[global.move_path_index].position) then
            -- waypoint reached
            global.move_path_index = global.move_path_index + 1  -- select the next waypoint
        end

        if global.move_path_index == #(global.move_path) then
            global.character_is_moving = false
            global.move_path_index = 1
			unsubscribe_on_tick_event(on_tick_move_event)
            script.raise_event(global.ASYNC_EXEC_COMPLETE)
        else
            -- move the character for one tick
            game.get_player(1).walking_state = {
                walking = true,
                direction = get_direction(character.position, global.move_path[global.move_path_index].position)
            }
        end
    end
end

-- For moving
-- Starts the movement process when the path is received.
script.on_event(defines.events.on_script_path_request_finished, function (event)
    if event.path then
		global.path_received = true
        global.character_is_moving = true
        global.move_path = event.path
        global.move_path_index = 1

		-- Debugging
        game.get_player(1).print(#(global.move_path))
    else 
        game.players[1].print("No path found")
		clog("No path found")
    end
end)

-- Main per-tick event handler
script.on_event(defines.events.on_tick, function(event)
    for _, subscriber in ipairs(on_tick_subscribers) do
        subscriber(event)
    end
end)


------------ Crafting ------------


script.on_event(defines.events.on_player_crafted_item, function(event)
    if event.item_stack == global.craft_recipe then
        if global.amount_crafted == global.amount_to_craft then
            global.craft_recipe = nil
            global.amount_crafted = 0
            global.amount_to_craft = 0
            script.raise_event(global.ASYNC_EXEC_COMPLETE)
        else
            global.amount_crafted = global.amount_crafted + 1
        end
    end
end)

------------ Mining ------------


-- Moves the character.
on_tick_mine_event = function(event)
    local character = game.get_player(1).character
	player.mining_state = {mining = true, position = global.mining_position}
end

script.on_event(defines.events.on_player_mined_entity, function(event)
    if global.is_mining_resource then
        if global.resources_left_to_mine >= global.resources_mined then
            -- Mining is complete
            -- Stop mining
            unsubscribe_on_tick_event(on_tick_mine_event)
            -- Reset globals
            global.mining_position = nil
            global.is_mining_resource = false
            global.resources_left_to_mine = 0
            global.resources_mined = 0
            -- Raise ASYNC complete
            script.raise_event(global.ASYNC_EXEC_COMPLETE)
        else
            global.resources_mined = global.resources_mined + 1
        end
    end

    if global.is_mining_entity then
        -- Mining is complete
        -- Stop mining
        unsubscribe_on_tick_event(on_tick_mine_event)
        -- Reset globals
        global.mining_position = nil
        global.is_mining_entity = false
        -- Raise ASYNC complete
        script.raise_event(global.ASYNC_EXEC_COMPLETE)
    end

end)





-- For debugging
-- remote.add_interface("primitives", {
--   move = move,
-- })









