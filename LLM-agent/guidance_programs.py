import guidance
import re

# we use GPT-4 here, but you could use gpt-3.5-turbo as well
guidance.llm = guidance.llms.OpenAI("gpt-3.5-turbo")



# a custom function we will call in the guidance program
def parse_best(prosandcons, options):
    best = int(re.findall(r'Best=(\d+)', prosandcons)[0])
    return options[best]

# define the guidance program using role tags (like `{{#system}}...{{/system}}`)
# TODO: Construct this prompt
craft_red_science_v1 = guidance('''
{{#system~}}
    You are 'FactorioAgent', an intelligent agent skilled in the pc game Factorio. You have played over 2000 hours and you are thus an expert. Your only goal is to craft a single red science. 
{{~/system}}

{{! generate five potential ways to accomplish a goal }}
{{#block hidden=True}}
{{#user~}}
I want to {{goal}}.
{{~! generate potential options ~}}
Can you please generate one option for how to accomplish this?
Please make the option very short, at most one line.
{{~/user}}

{{#assistant~}}
{{gen 'options' n=5 temperature=1.0 max_tokens=500}}
{{~/assistant}}
{{/block}}

{{! generate pros and cons for each option and select the best option }}
{{#block hidden=True}}
{{#user~}}
I want to {{goal}}.

Can you please comment on the pros and cons of each of the following options, and then pick the best option?
---{{#each options}}
Option {{@index}}: {{this}}{{/each}}
---
Please discuss each option very briefly (one line for pros, one for cons), and end by saying Best=X, where X is the best option.
{{~/user}}

{{#assistant~}}
{{gen 'prosandcons' temperature=0.0 max_tokens=500}}
{{~/assistant}}
{{/block}}

{{! generate a plan to accomplish the chosen option }}
{{#user~}}
I want to {{goal}}.
{{~! Create a plan }}
Here is my plan:
{{parse_best prosandcons options}}
Please elaborate on this plan, and tell me how to best accomplish it.
{{~/user}}

{{#assistant~}}
{{gen 'plan' max_tokens=500}}
{{~/assistant}}''')

# execute the program for a specific goal
out = create_plan(
    goal='read more books',
    parse_best=parse_best # a custom python function we call in the program
)

print(out)























# a custom function we will call in the guidance program
def parse_best(prosandcons, options):
    best = int(re.findall(r'Best=(\d+)', prosandcons)[0])
    return options[best]

# define the guidance program using role tags (like `{{#system}}...{{/system}}`)
create_plan = guidance('''
{{#system~}}
You are a helpful assistant.
{{~/system}}

{{! generate five potential ways to accomplish a goal }}
{{#block hidden=True}}
{{#user~}}
I want to {{goal}}.
{{~! generate potential options ~}}
Can you please generate one option for how to accomplish this?
Please make the option very short, at most one line.
{{~/user}}

{{#assistant~}}
{{gen 'options' n=5 temperature=1.0 max_tokens=500}}
{{~/assistant}}
{{/block}}

{{! generate pros and cons for each option and select the best option }}
{{#block hidden=True}}
{{#user~}}
I want to {{goal}}.

Can you please comment on the pros and cons of each of the following options, and then pick the best option?
---{{#each options}}
Option {{@index}}: {{this}}{{/each}}
---
Please discuss each option very briefly (one line for pros, one for cons), and end by saying Best=X, where X is the best option.
{{~/user}}

{{#assistant~}}
{{gen 'prosandcons' temperature=0.0 max_tokens=500}}
{{~/assistant}}
{{/block}}

{{! generate a plan to accomplish the chosen option }}
{{#user~}}
I want to {{goal}}.
{{~! Create a plan }}
Here is my plan:
{{parse_best prosandcons options}}
Please elaborate on this plan, and tell me how to best accomplish it.
{{~/user}}

{{#assistant~}}
{{gen 'plan' max_tokens=500}}
{{~/assistant}}''')

# execute the program for a specific goal
out = create_plan(
    goal='read more books',
    parse_best=parse_best # a custom python function we call in the program
)

print(out)

