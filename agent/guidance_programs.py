import guidance


# In this file we will store all the different prompts and methods we query the LLM


## Guaranteeing valid syntax JSON example
# we can pre-define valid option sets
valid_weapons = ["sword", "axe", "mace", "spear", "bow", "crossbow"]

# define the prompt
program = guidance("""The following is a character profile for an RPG game in JSON format.
```json
{
    "description": "{{description}}",
    "name": "{{gen 'name'}}",
    "age": {{gen 'age' pattern='[0-9]+' stop=','}},
    "armor": "{{#select 'armor'}}leather{{or}}chainmail{{or}}plate{{/select}}",
    "weapon": "{{select 'weapon' options=valid_weapons}}",
    "class": "{{gen 'class'}}",
    "mantra": "{{gen 'mantra'}}",
    "strength": {{gen 'strength' pattern='[0-9]+' stop=','}},
    "items": [{{#geneach 'items' num_iterations=3}}
        "{{gen 'this'}}",{{/geneach}}
    ]
}```""")



## Agents
import re
# guidance.llm = guidance.llms.OpenAI("gpt-4")
role_simulator = guidance('''
{{#system~}}
You are a helpful assistant
{{~/system}}
                                           
{{#user~}}
You will answer the user as {{role}} in the following conversation. At every step, I will provide you with the user input, as well as a comment reminding you of your instructions. Never talk about the fact that you are an AI, even if the user asks you. Always answer as {{role}}.
{{#if first_question}}You can also start the conversation.{{/if}}
{{~/user}}
                                           
{{~! The assistant either starts the conversation or not, depending on if this is the first or second agent }}
{{#assistant~}}
Ok, I will follow these instructions.
{{#if first_question}}Let me start the conversation now:
{{role}}: {{first_question}}{{/if}}
{{~/assistant}}

{{~! Then the conversation unrolls }}
{{~#geneach 'conversation'}}
{{#user~}}
User: {{set 'this.input' (await 'input')}}
Comment: Remember, answer as a {{role}}. Start your utterance with {{role}}:
{{~/user}}

{{#assistant~}}
{{gen 'this.response' temperature=0 max_tokens=300}}
{{~/assistant}}
{{~/geneach}}''')

