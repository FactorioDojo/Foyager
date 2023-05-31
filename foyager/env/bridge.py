import os.path
import time
import warnings
from typing import SupportsFloat, Any, Tuple, Dict
from server.server import FactorioServer
from rcon.source import Client
import json
import utils as U
import uuid

# We will not be using a javascript server
class FoyagerEnv():
    def __init__(
        self,
        server_ip="127.0.0.1",
        rcon_port= 27015,
        rcon_password= None,
        player_id=1,
        log_path="/opt/factorio/factorio-current.log",
    ):
        self.player_id = player_id
        self.log_path = log_path
        self.client = Client(server_ip, rcon_port, passwd=rcon_password)

    def observe(self,entities):
        with self.client as client:
            for entity in entities:
                client.run(f"/c remote.call('writeouts', 'writeout_filtered_entities', '{entity}') ")

    def step(
        self,
        function_name: str,
        code: str
    ) -> json:
        
        load_message_id = uuid.uuid4()
        self.client.run(f"/c remote.call('scripts', 'load_script', '{load_message_id}', '{function_name}', '{code}'")
        
        execute_message_id = uuid.uuid4()
        self.client.run(f"/c remote.call('scipts', 'execute_script', '{execute_message_id}', '{function_name})")
        return self.get_response(load_message_id, execute_message_id)

    def get_response(self, message_id) -> json:
        
        if not os.path.isfile():
            raise FileNotFoundError(self.log_path + " cannot be found")
        else:
            with open(self.log_path) as f:
                content = f.read().splitlines()
        raise NotImplementedError()

    def render(self):
        raise NotImplementedError("render is not implemented")
    
    """
    Resets the factorio environment.
    
    Args:
        options: options={
                    "mode": "soft"/"hard",
                    "wait_ticks": How many ticks to wait,
    Returns:
        None
    """
    def reset(self,options=None,):
        if options["mode"] == "soft":
            # reload mods to wipe game state
            with self.client as client:
                client.run(f"/c game.reload_mods()")
        elif options["mode"] == "hard":
            # TODO: Run console command to wipe (((everything)))
            raise NotImplementedError()

        if options["wait_ticks"] != 0:
            # TODO: Have the agent idle for a number of ticks
            raise NotImplementedError()
        
        self.has_reset = True
        # All the reset in step will be soft
        self.reset_options["reset"] = "soft"
