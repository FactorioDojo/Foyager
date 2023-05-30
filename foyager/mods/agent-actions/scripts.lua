local base64 = require("base64")
scripts = {}

function print_player(msg)
    game.players[1].print(msg)
end

function print_log(msg)
    log(msg)
end


-- Loads in a script encoded in base64, saves it to the global context
local function load_script(function_name, script)
    -- Decode the script string
	local script_string = base64.decode(script)
    local loaded_chunk, err_msg = loadstring(script_string)
    
    -- If there's an error during loading, log it and return
    if loaded_chunk == nil then
        log("Error loading script: " .. err_msg)
        return
    end

    -- Try running the function and catching any runtime errors
    local ok, script_fn = pcall(loaded_chunk)

    -- If there's a runtime error, log it and return
    if not ok then
        log("Error running script: " .. script_fn)  -- script_fn contains error message in this case
        return
    end

    _G[function_name] = script_fn  -- Only set the global function if there were no errors
end

-- Executes a script
local function execute_script(function_name, ...)
    if _G[function_name] then
        local ok, err = pcall(_G[function_name], ...)
        if not ok then
            log("Error executing script " .. function_name .. ": " .. err)
        end
    else
        log("Error: Function " .. function_name .. " does not exist.")
    end
end

    remote.add_interface("scripts", {
    load_script=load_script,
    execute_script=execute_script
      })

return scripts
