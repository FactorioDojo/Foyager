import os
import json
import openai

from rcon.source import Client
# from helpers import process_initial_file

from actions import Actions
from writeouts import Writeouts


# init_file = "/opt/factorio/script-output/init_out.txt"
# initial_data_file = 'data/initial_data.json'


actions = Actions(1)
writeouts = Writeouts()

writeouts.resources()
# actions.set_waypoint('''{{0,0}}''')
