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



-- Main per-tick event handler
script.on_event(defines.events.on_tick, function(event)
    for _, subscriber in ipairs(on_tick_subscribers) do
        subscriber(event)
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




