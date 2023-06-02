from foyager import Foyager
import os

openai_api_key = os.environ['OPENAI_API_KEY']

voyager = Foyager(
    server_ip = "127.0.0.1",
    rcon_port= 27015,
    rcon_password= '123',
    openai_api_key=openai_api_key,
)

# start lifelong learning
voyager.learn()