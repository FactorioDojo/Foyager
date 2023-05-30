local base64 = require("base64")
scripts = {}

function DEBUG(msg)
    game.players[1].print(msg)
end


-- Loads in a script encoded in base64, saves it to the global context
local function load_script(function_name, script)
    -- Decode the script string
	local script_string = base64.decode(script)
    -- Load it as lua code
    -- TODO: Error handling
	loaded_chunk = assert(loadstring(script_string))
	-- Attach function handle
    script_fn = loaded_chunk()
    -- Save to global context
    _G[function_name] = script_fn
end

-- Executes a script
local function execute_script(function_name, ...)
    _G[function_name](...)
end

    remote.add_interface("scripts", {
    load_script=load_script,
    execute_script=execute_script
      })

return scripts
