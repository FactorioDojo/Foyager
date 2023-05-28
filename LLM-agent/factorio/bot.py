from env import FoyagerEnv
from inventory import Inventory
from pathfinder import Pathfinder
from surroundings import Surroundings

# '''
#     Ensure that every function which performs a check on local entity information or inventory information has the most up-to-date information
# '''

async def get_response(message_id):
   # Get response message from IRC
   pass 

def response(func):
    async def wrapper(self, *args, **kwargs):
        # Call the desired function
        await func(self, *args, **kwargs)
        # Find the response from the chat logs
        return await get_response(kwargs['message_id'])
    return wrapper

class Bot():
    def __init__(self):
       self.inventory = Inventory()
       self.pathfinder = Pathfinder()
       self.surroundings = Surroundings()

    @response
    async def build(self, position, item, direction):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {direction})")

    @response
    async def craft(self, count, recipe):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {count}, {recipe})")

    @response
    async def move(self, destination):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {destination})")

    @response
    async def put(self, position, item, amount, inventory):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {amount}, {inventory})")

    @response
    async def take(self, position, item, amount, inventory):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {amount}, {inventory})")

    @response
    async def chat(self, message):
        pass

    @response
    async def cancel_tasks(self):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_cancel_tasks')")

    @response
    async def resources(self):
        with self.client as client:
            FoyagerEnv.client.run("/c remote.call('writeouts','writeout_resources')")

    @response
    async def inventory(self):
        with self.client as client:
            FoyagerEnv.client.run("/c remote.call('writeouts','writeout_inventory')")
            