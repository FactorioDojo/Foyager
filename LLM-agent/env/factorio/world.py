class World():
    def __init__(self):
        # Tile entities
        self.ore_patches = {}
        
        # Building entities
        self.belts = {}
        self.furnaces = {}
        self.buildings = {}
        self.inserters = {}
        
    """
        Find the closest ore tile to the bot
        
        Args:
            oretype: Which type of ore
            
        Returns:
            tuple: The position of the closest ore tile
    """
    def find_ore_patch(oretype):
       raise NotImplementedError() 
    
    
    """
        Find the closest water tile to the bot
            
        Returns:
            tuple: The position of the closest water tile
    """
    def find_water_source():
       raise NotImplementedError() 
 
    
    """
        Find the closest building to the bot
            
        Args:
            building: Which type of building   
            
        Returns:
            tuple: The position of the closest water tile
    """
    def find_closest_building(building):
        raise NotImplementedError()
    

   
    #    async def resources(self):
    #     with self.client as client:
    #         FoyagerEnv.client.run("/c remote.call('writeouts','writeout_resources')")

