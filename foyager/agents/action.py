from langchain.chat_models import ChatOpenAI
from langchain.chat_models import ChatOpenAI
from langchain.prompts import SystemMessagePromptTemplate
from langchain.schema import AIMessage, HumanMessage, SystemMessage
from prompts import load_prompt
from sklearn.cluster import MeanShift
import pandas as pd
from collections import defaultdict
import numpy as np
import json

resources = "/opt/factorio/script-output/resource_data.json"

class ActionAgent:
    def __init__(
        self,
        model_name="gpt-3.5-turbo",
        temperature=0,
        request_timout=120,
        ckpt_dir="ckpt",
        resume=False,
        chat_log=True,
        execution_error=True,
    ):
        self.ckpt_dir = ckpt_dir
        self.chat_log = chat_log
        self.execution_error = execution_error
        # U.f_mkdir(f"{ckpt_dir}/action")
        # if resume:
        #     print(f"\033[32mLoading Action Agent from {ckpt_dir}/action\033[0m")
        #     self.chest_memory = U.load_json(f"{ckpt_dir}/action/chest_memory.json")
        # else:
        #     self.chest_memory = {}
        self.llm = ChatOpenAI(
            model_name=model_name,
            temperature=temperature,
            request_timeout=request_timout,
        )
        
    '''
        Save entity information to /action/entity_memory.json
    '''
    def update_entity_memory(self):
        pass
    
    '''
        Save inventory information to /action/inventory_memory.json
    '''
    def update_inventory_memory(self):
        pass

    def update_resource_memory(self, entities):
        '''
        Save resource information to /action/resource_memory.json
        '''

        # Group entities by type
        entities_by_type = defaultdict(list)
        for entity in entities:
            entities_by_type[entity['entity_type']].append(entity['position'])

        # Calculate bounding box for each entity type
        result = {}
        for entity_type, positions in entities_by_type.items():
            df = pd.DataFrame(positions)

            # Perform Mean Shift clustering
            ms = MeanShift()
            clusters = ms.fit_predict(df)

            # Calculate bounding box for each cluster
            result[entity_type] = []
            for cluster_id in np.unique(clusters):
                cluster_positions = df[clusters == cluster_id]
                min_x = cluster_positions['x'].min()
                max_x = cluster_positions['x'].max()
                min_y = cluster_positions['y'].min()
                max_y = cluster_positions['y'].max()

                result[entity_type].append({
                    'count': len(cluster_positions),
                    'bounding_box': {
                        'min': {'x': min_x, 'y': min_y},
                        'max': {'x': max_x, 'y': max_y},
                    }
                })

        # Save the result to a JSON file
        with open('/action/resource_memory.json', 'w') as f:
            json.dump(result, f)
    
    def render_system_message(self, skills=[]):
        system_template = load_prompt("action_template")
        # FIXME: Hardcoded control_primitives
        base_skills = [
            "exploreUntil",
            "mineBlock",
            "craftItem",
            "placeItem",
            "smeltItem",
            "killMob",
        ]
        if not self.llm.model_name == "gpt-3.5-turbo":
            base_skills += [
                "useChest",
                "mineflayer",
            ]
        programs = "\n\n".join(load_control_primitives_context(base_skills) + skills)
        response_format = load_prompt("action_response_format")
        system_message_prompt = SystemMessagePromptTemplate.from_template(
            system_template
        )
        system_message = system_message_prompt.format(
            programs=programs, response_format=response_format
        )
        assert isinstance(system_message, SystemMessage)
        return system_message
    def process_ai_message(self, message):
        # assert isinstance(message, AIMessage)

        retry = 3
        error = None
        while retry > 0:
            try:
                code_pattern = re.compile(r"```(?:python|py)(.*?)```", re.DOTALL)
                code = "\n".join(code_pattern.findall(message.content))
                functions = []
                # Extract the function names, parameters and body from the code (if necessary)
                # ...

                # find the last async function
                main_function = None
                for function in reversed(functions):
                    if function["type"] == "AsyncFunctionDeclaration":
                        main_function = function
                        break

                assert (
                    main_function is not None
                ), "No async function found. Your main function must be async."
                assert (
                    len(main_function["params"]) == 1
                    and main_function["params"][0].name == "bot"
                ), f"Main function {main_function['name']} must take a single argument named 'bot'"
                
                program_code = "\n\n".join(function["body"] for function in functions)
                exec_code = f"await {main_function['name']}(bot);"

                # Define an empty dictionary as local and global context for the exec function
                context = {}

                # Then execute the program code and the exec code separately
                exec(program_code, context)
                exec(exec_code, context)
                return {
                    "program_code": program_code,
                    "program_name": main_function["name"],
                    "exec_code": exec_code,
                }
            except Exception as e:
                retry -= 1
                error = e
                time.sleep(1)
        return f"Error parsing action response (before program execution): {error}"