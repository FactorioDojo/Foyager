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
import utils as U
from control_primitives_context import load_control_primitives_context
import regex as re
import time

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

    """
        Save entity information to /action/entity_memory.json
    """

    def update_entity_memory(self):
        pass

    """
        Save inventory information to /action/inventory_memory.json
    """

    def update_inventory_memory(self):
        pass

    def update_resource_memory(self):
        """
        Save resource information to /action/resource_memory.json
        """
        deposits = U.mod_utils.resource_clustering()
        U.dump_json(deposits, f"{self.ckpt_dir}/action/resources.json")

    def render_system_message(self, skills=[]):
        system_template = load_prompt("action_template")
        # FIXME: Hardcoded control_primitives
        base_skills = [
            "move",
            "mine_resource",
            "route_belt",
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
    
    def render_human_message(
        self, *, events, code="", task="", context="", critique=""
    ):
        chat_messages = []
        error_messages = []
        
        observation = ""

        if code:
            observation += f"Code from the last round:\n{code}\n\n"
        else:
            observation += f"Code from the last round: No code in the first round\n\n"

        if self.execution_error:
            if error_messages:
                error = "\n".join(error_messages)
                observation += f"Execution error:\n{error}\n\n"
            else:
                observation += f"Execution error: No error\n\n"

        if self.chat_log:
            if chat_messages:
                chat_log = "\n".join(chat_messages)
                observation += f"Chat log: {chat_log}\n\n"
            else:
                observation += f"Chat log: None\n\n"

        # observation += f"Health: {health:.1f}/20\n\n"

        observation += f"Entity observations around the player:\n"

        for event in events:
            for key,value in event.items():
                observation += f"{key} - {value}\n"

        # observation += f"Position: x={position['x']:.1f}, y={position['y']:.1f}\n\n"

        observation += f"Task: {task}\n\n"

        if context:
            observation += f"Context: {context}\n\n"
        else:
            observation += f"Context: None\n\n"

        if critique:
            observation += f"Critique: {critique}\n\n"
        else:
            observation += f"Critique: None\n\n"

        return HumanMessage(content=observation)
