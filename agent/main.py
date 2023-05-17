import os
import json

import secrets

# from helpers import process_initial_file

from factorio import Factorio 
from agent import Agent


'''
Roughly: 

- 'agent.py' uses 'guidance' to query LLM for instructions. 
- If interactive_mode is enabled, then a human is able to modify each query to the LLM. If it is disabled we use an autonomous routine (for later)
- These instructions are parsed and then sent as actions in `factorio.py`.
- 'agent.py' then query 'factorio.py' for the response of the environment to the action, or for a writeout of the environment generally.
'''



agent = Agent(factorio=Factorio(), interactive_mode=True)
