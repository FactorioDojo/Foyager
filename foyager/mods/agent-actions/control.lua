require ("util")
task = require ("tasks")
scripts = require("scripts")
writeouts = require("writeouts")
actions = require("actions")

on_tick_subscribers = {}

-- last_positions = {}


-- local destination = {x = 0, y = 0}
-- local state = 1
-- local was_walking = 0
-- local idle = 0
-- local pick = 0
-- local dropping = 0
--Uncomment this for the better mining handling fix
--local mining_done = 0


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


-- Main per-tick event handler
script.on_event(defines.events.on_tick, function(event)
	for subscriber in on_tick_subscribers do
		subscriber()
	end
end)


-- Initializes the movement process when the path is received.
script.on_event(defines.events.on_script_path_request_finished, function (event)
    if event.path then
        character_is_moving = true
        path = event.path
        path_index = 1
        game.get_player(1).print(#path)
    else 
        game.players[1].print("No path found")
    end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)

end)

-- For debugging
remote.add_interface("primitives", {
  move = move,
})








