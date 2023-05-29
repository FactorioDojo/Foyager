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
            