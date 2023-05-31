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
        function_name: str,
        code: str
    ) -> json:
        
        message_id = uuid.uuid4()
        self.client.run(f"/c remote.call('scripts', 'load_script', '{message_id}', '{function_name}', '{code}'")
        self.client.run(f"/c remote.call('scipts', 'execute_script', '{message_id}', '{function_name})")
        return self.get_response(message_id)

    def get_response(message_id) -> json:
        # Scrape the factorio log file here, return as json (idk the format)
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
