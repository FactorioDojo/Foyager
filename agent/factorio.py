from rcon.source import Client

class Factorio():
    def __init__(self,player_id):
        self.player_id = player_id
        self.client = Client('127.0.0.1', 27015, passwd='123')

    def test(self):
        with self.client as client:
            client.run("/c remote.call('actions', 'add_task', 'move', {0.0, 0.0})")


    def set_waypoint(self,waypoint):
        with self.client as client:
            client.run(f"/c remote.call('actions','set_waypoints',{self.player_id},{waypoint})")


    def set_mining_target(self,entity_name,pos):
        with self.client as client:
            client.run(f"remote.call('actions','mining_target',{self.player_id},{entity_name},{pos}")

    def resources(self):
        with self.client as client:
            client.run("/c remote.call('writeouts','writeout_resources')")

    def inventory(self):
        with self.client as client:
            client.run("/c remote.call('writeouts','writeout_inventory')")

