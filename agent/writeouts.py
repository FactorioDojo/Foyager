from rcon.source import Client


class Writeouts():
    def __init__(self):
        self.client = Client('127.0.0.1', 27015, passwd='soo8UiSheeph4th')

    def resources(self):
        with self.client as client:
            client.run("/c remote.call('writeouts','writeout_resources')")

    def inventory(self):
        with self.client as client:
            client.run("/c remote.call('writeouts','writeout_inventory')")

