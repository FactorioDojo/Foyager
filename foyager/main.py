from foyager import Foyager
import os

openai_api_key = os.environ['OPENAI_API_KEY']
anthropic_api_key = os.environ['ANTHROPIC_API_KEY']

voyager = Foyager(
    server_ip = "127.0.0.1",
    rcon_port= 27015,
    rcon_password= '123',
    openai_api_key=openai_api_key,
    anthropic_api_key=anthropic_api_key
    # curriculum_agent_mode='manual',
)

# start lifelong learning
voyager.learn()