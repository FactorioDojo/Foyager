from env import FoyagerEnv

class Inventory():
    def __init__(self):
       self.contents = {}
       
    def has_item(item):
        raise NotImplementedError() 
    
    
    # This function needs to be called by the main agent program
    # async def inventory(self):
    #     with self.client as client:
    #         FoyagerEnv.client.run("/c remote.call('writeouts','writeout_inventory')")
           
           
     """
        Crafts the specified item
        
        Args:
           recipie: Which item to craft 
           count: How many of the item to craft
        Raises:
            --    
    """
    async def craft(self, count, recipe):
        # Ensure the item is valid
        if not item in self.item_catalog:
            raise Exception("Item ", {item}, " does not exist.")
        
        # Ensure the player has the item in its inventory
        if not item in self.inventory.inventory:
            raise Exception("Player does not have", {item}, " in inventory.") 
        