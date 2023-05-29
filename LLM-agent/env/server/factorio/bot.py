from env import FoyagerEnv
from inventory import Inventory
from pathfinder import Pathfinder
from world import World 
import game_definitions as gd
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
        self.position = (0,0)
        self.inventory = Inventory()
        self.pathfinder = Pathfinder()
        self.surroundings = World()

    """
        Ensures the bot is within reaching distance of the position
        
        Args:
            position: The position in question
            
        Returns:
            bool: True if the agent is nearby, false otherwise
    """
    def is_near(self, position):
       if ((self.position.x - position.x)**2 + (self.position.y - position.y)**2)**(1/2) <= gd.reach_distance:
           return True
       return False

    """
        Builds the item at the specified position and direction
        
        Args:
           position: The world position of the building
           item: Which item to build
           direction: Which direction the building will face
            
        Raises:
            --    
    """
    async def build(self, position, item, direction):
        # Ensure the player is within reaching distance 
        if not self.is_near(position):
            raise Exception("You are not close enough to the target position")
        
        # Ensure the item is valid
        if not item in self.item_catalog:
            raise Exception("Item ", {item}, " does not exist.")
        
        # Ensure the player has the item in its inventory
        if not item in self.inventory.inventory:
            raise Exception("Player does not have", {item}, " in inventory.") 
        
        # Ensure the direction is valid
        if not direction in gd.directions:
            raise Exception("Invalid direction: ", {direction})
        
        # Ensure the building position is not occupied
        #TODO: Finish
        
    """
        Crafts the specified item
        
        Args:
           recipie: Which item to craft 
           count: How many of the item to craft
        Raises:
            --    
    """
    async def craft(self, count, recipe):
        
    
    async def _build(self, position, item, direction):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {direction})")

    async def _craft(self, count, recipe):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {count}, {recipe})")

    async def _move(self, destination):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {destination})")

    async def _put(self, position, item, amount, inventory):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {amount}, {inventory})")

    async def _take(self, position, item, amount, inventory):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {amount}, {inventory})")

    async def chat(self, message):
        pass

    async def cancel_tasks(self):
        with self.client as client:
            FoyagerEnv.client.run(f"/c remote.call('actions','rcon_cancel_tasks')")

