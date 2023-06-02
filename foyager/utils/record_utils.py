import time

from .file_utils import *
from .json_utils import *


class EventRecorder:
    def __init__(
        self,
        ckpt_dir="ckpt",
    ):
        self.ckpt_dir = ckpt_dir
        self.iteration = 0
        f_mkdir(self.ckpt_dir, "events")

    def record(self, events, task):
        task = re.sub(r'[\\/:"*?<>| ]', "_", task)
        task = task.replace(" ", "_") + time.strftime(
            "_%Y%m%d_%H%M%S", time.localtime()
        )
        events = {self.iteration: events}
        dump_json(events, f_join(self.ckpt_dir, "events", task))

        self.iteration += 1
