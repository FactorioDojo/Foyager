import re
import uuid

control_primitive_script_1 = \
'''
function mine_resource(ore_type, quantity)
    -- Check if arguments are valid
    if type(ore_type) ~= 'string' or type(quantity) ~= 'number' then
        clog("Invalid arguments. 'ore_type' should be a string and 'quantity' should be a number.")
        return false
    end

  
    -- Check if the ore type exists
    if not resource then
        clog("No resource of type " .. ore_type .. " found.")
        return false
    end

    local player = game.players[1]

    -- Check if the player is in a valid state
    if not player.character or player.character.mining_state.mining then
        clog("Player is not in a valid state for mining.")
        return false
    end

    -- Find nearest ore entity
    local position = player.character.position
    local surface = player.surface
    local resource_position = find_nearest_ore(surface, position, ore_type)

    -- Move to ore position
    await move(resource_position)

    -- Mining loop
    await mine(resouce_position, quantity)

    -- If the mining process was successful, return true
    return true
end

return mine_resource
'''

control_primitive_script_2 = \
'''
function mine_resource(ore_type, quantity)
    local player = game.players[1]

    -- Move to ore position
    await move(resource_position)

    for _ in
end

return mine_resource
'''


event_function_open_str = \
'''
script.on_event({event_id}, function(event)
'''


EVENT_SUCCESS = 'global.SCRIPT_SUCCESS_EVENT'
EVENT_FAIL = 'global.SCRIPT_FAILED_EVENT'

# Unique event names generator
def generate_name():
    return f"event_{uuid.uuid4().hex}"
    
# TODO: If function has await anywhere, raise global.ASYNC_EXEC_COMPLETE at the end of the last event function
def compile_to_rlua(source_lua):

    # If there is no await keyword in this function, we do not need to compile it to rLua
    await_kwd = re.search(r'await\s+([a-zA-Z_][a-zA-Z_0-9]*)', source_lua)
    if not await_kwd:
        return source_lua


    # Table of event ptrs
    event_ptrs = {}

    # Find the last occurrence of "end"
    last_end_index = source_lua.rfind("end")

    # If "end" was found, slice the string up to and including that point
    if last_end_index != -1:
        truncated_source_lua = source_lua[:last_end_index]
        
    # Tokenize into lines
    lines = truncated_source_lua.split("\n")
        
    # List to store the new code
    output = []
    
    # Extract main function name
    main_function_name = re.search(r'(function)\s([a-zA-Z_][a-zA-Z_0-9]*)', source_lua)   
    
    if not main_function_name:
        print("Failed to find function name")
        return
    
    main_function_name = main_function_name.group(2)
    
    
    # Set flag for special case end instead of end) for the first function
    first_function = True
    
    # Generate the first ptr
    current_event = generate_name()
    
    for line in lines:
        print('====================')
        print('line ', line)
        for l in output:
            print(l)
            print('--------------')
        
        # If comment, append and move on
        comment_kwd = re.search(r'--\s+([a-zA-Z_][a-zA-Z_0-9]*)', line)   
        
        if comment_kwd: 
            output.append(line)
            continue
            
        # Search for the await keyword
        await_kwd = re.search(r'await\s+([a-zA-Z_][a-zA-Z_0-9]*)', line)
        
        # Search for the return keyword
        return_kwd = re.search(r'return\s+([a-zA-Z_][a-zA-Z_0-9]*)', line)
        
        if await_kwd:
            # Append the command without await
            output.append(re.sub(r'(\s*)await(\s*)', r'\1\2', line))
            
            # Close current event and start a new one
            if first_function:
                output.append(f"end  -- end of " + main_function_name)
            else:
                output.append(f"end)  -- end of {current_event}")
                
            # Generate new event name
            next_event = generate_name()

            # Update timelines
            if first_function:
                event_ptrs[main_function_name] = next_event
            else:
                event_ptrs[current_event] = next_event

            # Start a new event
            output.append(event_function_open_str.format(event_id=next_event))
            
            current_event = next_event
            
            if first_function: first_function = False
        elif return_kwd:
            true_kwd = re.search(r'true', line)
            false_kwd = re.search(r'false', line)
            function_name_pattern = main_function_name+'\s+([a-zA-Z_][a-zA-Z_0-9]*)'
            function_name_kwd = re.search(function_name_pattern, line)
            
            if true_kwd:
                output.append(re.sub(r'(\s*)return(\s*)true', r'\1raise_event({status})\2'.format(status=EVENT_SUCCESS), line))
            elif false_kwd:
                output.append(re.sub(r'(\s*)return(\s*)false', r'\1raise_event({status})\2'.format(status=EVENT_FAIL), line))
            elif function_name_kwd:
                # Remove line
                pass
            
        else:
            # Regular line, just append to the output
            output.append(line)
        
        # input()

    # Close the last event
    output.append(f"end)  -- end of {current_event}")

    # Add the global ptr table to the output
    event_ptrs_str = ''
    for ptr in event_ptrs:
        event_ptrs_str += 'global.event_ptrs[\'{ptr}\'] = {value}'.format(
            ptr = ptr,
            value = event_ptrs[ptr] 
        )+'\n'
        
        
    # Add the global event table to the output
    events_str = ''
    for ptr in event_ptrs:
        events_str += 'global.events[\'{ptr}\'] = generate_event_name()'.format(
            ptr = ptr,
        )+'\n'
        events_str += 'global.events[\'{ptr}\'] = generate_event_name()'.format(
            ptr = event_ptrs[ptr],
        )+'\n'


         
    output.insert(0, event_ptrs_str)
    output.insert(0, events_str)
    
    output.append('\n return ' + main_function_name)
    
    return "\n".join(output)

source_rlua = compile_to_rlua(control_primitive_script_1)
print(source_rlua)