import os
import secret_keys

# Set API key

if not secret_keys.OPENAI_API_KEY:
    print("Please set OPENAI_API_KEY in file secret_keys.py")
    exit()

os.environ["OPENAI_API_KEY"] = secret_keys.OPENAI_API_KEY 