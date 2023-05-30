local base64 = require("base64")
scripts = {}

function DEBUG(msg)
    game.players[1].print(msg)
end


-- Loads in a script encoded in base64, saves it to script table
local function load_script(function_name, script)
	local script_string = base64.decode(script)
	loaded_chunk = assert(loadstring(script_string))
	script_fn = loaded_chunk()
    scripts[function_name] = script_fn
end

-- Executes a script
local function execute_script(function_name, ...)
    scripts[function_name](...)
end

    remote.add_interface("scripts", {
    load_script=load_script,
    execute_script=execute_script
      })

return scripts
