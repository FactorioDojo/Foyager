local base64lib = require ("base64")
scripts = {}

-- Loads in a script encoded in base64, saves it to script table
local function load_script(script, function_name)
	script_string = base64lib.decode(script, base64lib.DEFAULT_DECODER, true)
	script_function = loadstring(script_string)
	scripts[function_name] = script_function
end

-- Executes a script
local function execute_script(function_name)
	scripts[function_name]()
end
      
  remote.add_interface("scripts", {
    load_script=load_script,
    execute_script=execute_script,
      })

return scripts 

