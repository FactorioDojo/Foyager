import os
import openai
import secret_keys
import guidance
import guidance_programs


# init_file = "/opt/factorio/script-output/init_out.txt"
# initial_data_file = 'data/initial_data.json'


class Agent():
    def __init__(self, factorio, interactive_mode):
        self.factorio = factorio 
        self.interactive_mode = interactive_mode
        
        # set the default language model used to execute guidance programs
        guidance.llm = guidance.llms.OpenAI("text-davinci-003")
    
    # Example of how this might work
    def run(self):
        if self.interactive_mode:
            republican = guidance_programs.role_simulator(role='Republican')
            democrat = guidance_programs.role_simulator(role='Democrat')

            first_question = '''What do you think is the best way to stop inflation?'''
            republican = republican(input=first_question, first_question=None)
            democrat = democrat(input=republican["conversation"][-2]["response"].strip('Republican: '), first_question=first_question)
            for i in range(2):
                republican = republican(input=democrat["conversation"][-2]["response"].replace('Democrat: ', ''))
                democrat = democrat(input=republican["conversation"][-2]["response"].replace('Republican: ', ''))
            print('Democrat: ' + first_question)
            for x in democrat['conversation'][:-1]:
                print('Republican:', x['input'])
                print()
                print(x['response'])
        else:
            # execute the prompt
            guidance_programs.program(description="A quick and nimble fighter.", valid_weapons=valid_weapons)
        
       

