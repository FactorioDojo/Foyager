import os.path
import time
import warnings
from typing import SupportsFloat, Any, Tuple, Dict
from server.server import FactorioServer
from rcon.source import Client
import requests
import json
import utils as U

# We will not be using a javascript server
class FoyagerEnv():
    def __init__(
        self,
        server_ip="127.0.0.1",
        rcon_port= 27015,
        rcon_password= None,
        player_id=1,
        request_timeout=600,
        log_path="./logs",
    ):
        self.client = Client(server_ip, rcon_port, passwd=rcon_password)
        self.server = FactorioServer(self.client)

    def observe(self,entities):
        with self.client as client:
            for entity in entities:
                client.run(f"/c remote.call('writeouts', 'writeout_filtered_entities', '{entity}') ")

    def step(
        self,
        name: str,
        code: str
    ):

        res = self.client.run(f"/c remote.call('scripts', 'load_script', 1, '{name}', '{code}'")

        if res.status_code != 200:
            raise RuntimeError("Failed to step Factorio server")
        returned_data = res.json()
        return json.loads(returned_data)

    def render(self):
        raise NotImplementedError("render is not implemented")

    def reset(self,options=None,):
        if options is None:
            options = {}
            # reload mods to wipe game state
            with self.client as client:
                client.run(f"/c game.reload_mods()")

    #     returned_data = self.check_process()
    #     self.has_reset = True
    #     self.connected = True
    #     # All the reset in step will be soft
    #     self.reset_options["reset"] = "soft"
    #     self.pause()
    #     return json.loads(returned_data)
