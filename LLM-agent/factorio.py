from rcon.source import Client

class FactorioInterface():
    def __init__(self,player_id):
        self.player_id = player_id
        self.client = Client('127.0.0.1', 27015, passwd='123')

    ## Primitive commands
    def build(self, position, item, direction):
        with self.client as client:
            client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {direction})")

    def craft(self, count, recipe):
        with self.client as client:
            client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {count}, {recipe})")

    def move(self, destination):
        with self.client as client:
            client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {destination})")

    def put(self, position, item, amount, inventory):
        with self.client as client:
            client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {amount}, {inventory})")

    def take(self, position, item, amount, inventory):
        with self.client as client:
            client.run(f"/c remote.call('actions','rcon_add_task', {self.player_id}, {position}, {item}, {amount}, {inventory})")

    def cancel_tasks(self):
        with self.client as client:
            client.run(f"/c remote.call('actions','rcon_cancel_tasks')")

    def resources(self):
        with self.client as client:
            client.run("/c remote.call('writeouts','writeout_resources')")

    def inventory(self):
        with self.client as client:
            client.run("/c remote.call('writeouts','writeout_inventory')")
            
    ## Abstract commands
    # TODO

