import re
import uuid



class rLuaCompiler:
    def __init__(self, source_code):
        # Internals
        self.source_code = source_code
        self.target_code = ""
        
        self.error_log = ""
        
        # Checks
        self.forbidden_keywords \
        = [
            "while",
            "for",
            "repeat",
            "do",
            "generate_event_name",
            "get_event_handler",
            "get_event_order",
            "set_event_filter",
            "get_event_filter",
            "raise_event",
            "raise_hover_events"
        ]
        
        # Predefined strings
        self.event_function_open_str = \
        '''
        script.on_event({event_id}, function(event)
        '''
        
        self.EVENT_SUCCESS = 'global.SCRIPT_SUCCESS_EVENT'
        self.EVENT_FAIL = 'global.SCRIPT_FAILED_EVENT'
        
    # Unique event names generator
    def generate_name(self):
        return f"event_{uuid.uuid4().hex}"
    
    def log_error(self, error):
        self.error_log += "\n" + error + "\n"
        

    #returns true if valid
    def is_valid(self, source_lua):
            #check for keywords, only is invalid if keyword appears if not bordered on at least one side by non whitespace character (excluding of course a trailing "(")
            for keyword in self.forbidden_keywords:
                pattern = fr"(?<!\S){re.escape(keyword)}(?!\S)|{re.escape(keyword)}\s*\("
                if(re.search(pattern, source_lua) is not None):
                    self.log_error("Error: Use of forbidden keyword", keyword)
                    return False
            #check for events
            pattern = r"script\.on_.*"
            if(re.search(pattern, source_lua) is not None):
                self.log_error("Error: Use of forbidden keyword script.on\nYou should not need to register any events with the factorio engine.")
                return False
            
            return True
    #returns true if await found in if statment
    def check_await_in_if_statements(self):
        # Regular expression pattern to match "if" statements containing "await"
        pattern = r"if\s*\(.*?\)\s*then\s*.*?\n\s*end"

        # Find all matches in the Lua code
        matches = re.findall(pattern, self.source_code, re.DOTALL)

        # Check if any matches contain the "await" keyword
        for match in matches:
            if "await" in match:
                return True

        # If no matches contain "await"
        return False


    # TODO: If function has await anywhere, raise global.ASYNC_EXEC_COMPLETE at the end of the last event function
    def compile_to_lua(self):
        #checks for compiler errors
        
        source_lua = self.source_code
        
        # If there is no await keyword in this function, we do not need to compile it to rLua
        await_kwd = re.search(r'await\s+([a-zA-Z_][a-zA-Z_0-9]*)', source_lua)
        if not await_kwd:
            self.target_code = source_lua
            return True


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
        current_event = self.generate_name()
        
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
                next_event = self.generate_name()

                # Update timelines
                if first_function:
                    event_ptrs[main_function_name] = next_event
                else:
                    event_ptrs[current_event] = next_event

                # Start a new event
                output.append(self.event_function_open_str.format(event_id=next_event))
                
                current_event = next_event
                
                if first_function: first_function = False
            elif return_kwd:
                true_kwd = re.search(r'true', line)
                false_kwd = re.search(r'false', line)
                function_name_pattern = main_function_name+'\s+([a-zA-Z_][a-zA-Z_0-9]*)'
                function_name_kwd = re.search(function_name_pattern, line)
                
                if true_kwd:
                    output.append(re.sub(r'(\s*)return(\s*)true', r'\1raise_event({status})\2'.format(status=self.EVENT_SUCCESS), line))
                elif false_kwd:
                    output.append(re.sub(r'(\s*)return(\s*)false', r'\1raise_event({status})\2'.format(status=self.EVENT_FAIL), line))
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
        
        self.target_code = output
        return True         



# source_lua = ""
# with open('tests/test_script_1.lua') as f:
#     source_rlua = f.read()

# print(source_rlua)

# compiler = rLuaCompiler(source_rlua)
# compiler.compile_to_rlua()
# for line in compiler.target_code:
#     print(line)