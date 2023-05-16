from rcon.source import Client

class Actions():
    def __init__(self,player_id):
        self.player_id = player_id
        self.client = Client('127.0.0.1', 27015, passwd='123')


    def test(self):
        with self.client as client:
            client.run(f"/c game.players[1].print(1234)")

    def set_waypoint(self,waypoint):
        with self.client as client:
            client.run(f"/c remote.call('actions','set_waypoints',{self.player_id},{waypoint})")


    def set_mining_target(self,entity_name,pos):
        with self.client as client:
            client.run(f"remote.call('actions','mining_target',{self.player_id},{entity_name},{pos}")

    # def insert_to_inventory(self,entity_name,pos,item_name):
    #      with self.client as client:
    #         client.run(f"/c remote.call('actions','insert_to_inventory',{self.player_id},{entity_name},{pos},{item2inventory_type[item]}{item_name})")