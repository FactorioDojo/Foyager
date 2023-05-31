require("util")
require("lib/log_utils")
scripts = require("scripts")
writeouts = require("writeouts")
actions = require("actions")


-- Tables of subscriber functions
on_tick_subscribers = {}

-- Global variables for the move function
global.path_received = false 
global.move_path = {}
global.move_path_index = 1
global.character_is_moving = false


-- local destination = {x = 0, y = 0}
-- local state = 1
-- local idle = 0
-- local pick = 0
-- local dropping = 0
--Uncomment this for the better mining handling fix
--local mining_done = 0


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
        else
            -- move the character for one tick
            game.get_player(1).walking_state = {
                walking = true,
                direction = get_direction(character.position, global.move_path[global.move_path_index].position)
            }
        end
    end
end


-- Main per-tick event handler
script.on_event(defines.events.on_tick, function(event)
    for _, subscriber in ipairs(on_tick_subscribers) do
        subscriber(event)
    end
end)



-- Initializes the movement process when the path is received.
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

-- script.on_event(defines.events.on_player_mined_entity, function(event)

-- end)

-- For debugging
remote.add_interface("primitives", {
  move = move,
})





-- This was used to close dialogs in the tutorial automatically. I'm guessing more
-- work needs to be done here.
-- local function clsobj(p)
-- 	p.gui.left.children[1].visible = false
-- 	return true
-- end


-- Skips the freeplay intro
-- script.on_event(defines.events.on_game_created_from_scenario, function()

-- 	remote.call("freeplay", "set_skip_intro", true)
-- 	speed(1)

-- end)




