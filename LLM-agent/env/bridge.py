import os.path
import time
import warnings
from typing import SupportsFloat, Any, Tuple, Dict

from rcon.source import Client
import requests
import json


import voyager.utils as U


# We will not be using a javascript server
class FoyagerEnv():
    def __init__(
        self,
        server_ip="127.0.0.1",
        server_port=27015,
        server_password="123",
        player_id=1,
        request_timeout=600,
        log_path="./logs",
    ):
        self.client = Client('127.0.0.1', 27015, passwd='123')

    #TODO: Change this to work with our local python server
    def step(
        self,
        code: str,
        programs: str = "",
    ) -> Tuple[ObsType, SupportsFloat, bool, bool, Dict[str, Any]]:
        if not self.has_reset:
            raise RuntimeError("Environment has not been reset yet")
        self.check_process()
        self.unpause()
        data = {
            "code": code,
            "programs": programs,
        }
        res = requests.post(
            f"{self.server}/step", json=data, timeout=self.request_timeout
        )
        if res.status_code != 200:
            raise RuntimeError("Failed to step Minecraft server")
        returned_data = res.json()
        self.pause()
        return json.loads(returned_data)

    # def render(self):
    #     raise NotImplementedError("render is not implemented")

    # def reset(
    #     self,
    #     *,
    #     seed=None,
    #     options=None,
    # ) -> Tuple[ObsType, Dict[str, Any]]:
    #     if options is None:
    #         options = {}

    #     if options.get("inventory", {}) and options.get("mode", "hard") != "hard":
    #         raise RuntimeError("inventory can only be set when options is hard")

    #     self.reset_options = {
    #         "port": self.mc_port,
    #         "reset": options.get("mode", "hard"),
    #         "inventory": options.get("inventory", {}),
    #         "equipment": options.get("equipment", []),
    #         "spread": options.get("spread", False),
    #         "waitTicks": options.get("wait_ticks", 5),
    #         "position": options.get("position", None),
    #     }

    #     self.unpause()
    #     self.mineflayer.stop()
    #     time.sleep(1)  # wait for mineflayer to exit

    #     returned_data = self.check_process()
    #     self.has_reset = True
    #     self.connected = True
    #     # All the reset in step will be soft
    #     self.reset_options["reset"] = "soft"
    #     self.pause()
    #     return json.loads(returned_data)

    # def close(self):
    #     pass
    #     self.unpause()
    #     if self.connected:
    #         res = requests.post(f"{self.server}/stop")
    #         if res.status_code == 200:
    #             self.connected = False
    #     if self.mc_instance:
    #         self.mc_instance.stop()
    #     self.mineflayer.stop()
    #     return not self.connected

    # def pause(self):
    #     if self.mineflayer.is_running and not self.server_paused:
    #         res = requests.post(f"{self.server}/pause")
    #         if res.status_code == 200:
    #             self.server_paused = True
    #     return self.server_paused

    # def unpause(self):
    #     if self.mineflayer.is_running and self.server_paused:
    #         res = requests.post(f"{self.server}/pause")
    #         if res.status_code == 200:
    #             self.server_paused = False
    #         else:
    #             print(res.json())
    #     return self.server_paused