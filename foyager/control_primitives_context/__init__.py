import pkg_resources
import os
import utils as U


def load_control_primitives_context(primitive_names=None):
    package_path = pkg_resources.resource_filename("foyager", "")
    if primitive_names is None:
        primitive_names = [
            primitives[:-3]
            for primitives in os.listdir(f"{package_path}/control_primitives_context")
            if primitives.endswith("lua")
        ]
    primitives = [
        U.load_text(f"{package_path}/control_primitives_context/{primitive_name}.lua")
        for primitive_name in primitive_names
    ]
    print (primitives)
    return primitives

