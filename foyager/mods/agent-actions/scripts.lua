local base64 = require("base64")
scripts = {}

function print_player(msg)
    game.players[1].print(msg)
end

-- Print log to file with msg_id attached for easier scraping
function id_log(msg_id, msg)
    log("Message ID: " .. msg_id .. " " ..msg)
end


-- Loads in a script encoded in base64, saves it to the global context
local function load_script(msg_id, function_name, script)
    -- Decode the script string
	local script_string = base64.decode(script)
    local loaded_chunk, err_msg = loadstring(script_string)
    
    -- If there's an error during loading, log it and return
    if loaded_chunk == nil then
        id_log(msg_id, "Error loading script" .. function_name .. ": " .. err_msg)
        return
    end
    
    id_log(msg_id, "Script " .. function_name .. " loaded successfully")

    -- Try running the function and catching any runtime errors
    local ok, script_fn = pcall(loaded_chunk)

    -- If there's a runtime error, log it and return
    if not ok then
        id_log(msg_id, "Error running script " .. function_name .. ": " .. script_fn)  -- script_fn contains error message in this case
        return
    end

    _G[function_name] = script_fn  -- Only set the global function if there were no errors
end

-- Executes a script
local function execute_script(msg_id, function_name, ...)
    if _G[function_name] then
        local ok, err = pcall(_G[function_name], ...)
        if not ok then
            id_log(msg_id, "Error executing script " .. function_name .. ": " .. err)
        else
            id_log(msg_id, "Script " .. function_name .. " executed successfully")
        end
    else
        id_log(msg_id, "Error: Function " .. function_name .. " does not exist.")
    end
end

    remote.add_interface("scripts", {
    load_script=load_script,
    execute_script=execute_script
      })

return scripts
