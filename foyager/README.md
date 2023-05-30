# foyager

## Overview


This agent is heavily based on the [Voyager agent](https://github.com/MineDojo/Voyager) made for minecraft. We have repurposed it to play factorio. Like Voyager, the agent consists of three key components: 1) an automatic curriculum that maximizes exploration, 2) an ever-growing skill library of executable code for storing and retrieving complex behaviors, and 3) a new iterative prompting mechanism that incorporates environment feedback, execution errors, and self-verification for program improvement.

The agent writes the programs using the native factorio lua API, which are loaded and executed during runtime.

Agents play on a randomly generated map, with the following conditions:
- No cliffs
- No trees
- No rocks
- No biters
- Water only near spawn position 


## Installing

### Requirements
- Factorio
- Docker


We use a docker environment to run a headless Factorio server ([original repository](https://github.com/factoriotools/factorio-docker)). Run the server to create the necessary folder structure and configuration files. For this example data is stored in `/opt/factorio`.

```shell
sudo mkdir -p /opt/factorio
sudo chown 845:845 /opt/factorio
sudo docker run -d \
  -p 34197:34197/udp \
  -p 27015:27015/tcp \
  -v /opt/factorio:/factorio \
  --name factorio \
  --restart=unless-stopped \
  factoriotools/factorio
```

Two mods are required, `agent-actions` and `agent-writeouts`. These are located in the `mods` folder. They should be installed to your Factorio mods folder in the same way as other mods, as well as the mods folder in the headless factorio server. 

A helper script to install this to your Factorio client mods folder is provided as `install.bat` (todo `install.sh`)

## Running

You will need an API key from OpenAI. You may get one of those [here](https://platform.openai.com/). Store your API key as an environment variable.

```
OPENAI_API_KEY = [your key] 
```

The agent is located in the `agent` folder and can be run with:

```
python main.py
```


# Results


| Model / Prompt / API Access | Automate Red Science | Automate Red Science | Automate Red Science | task | task | task | task | task | task | task | task | task | task | task | task | task | task | task | task | task | task |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| GPT3.5-turbo / 1A / 1 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT3.5-turbo / 1A / 2 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT3.5-turbo / 1A / 3 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT3.5-turbo / 1B / 1 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT3.5-turbo / 1B / 2 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT3.5-turbo / 1B / 3 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT4 / 1B / 1 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT4 / 1B / 2 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |
| GPT4 / 1B / 3 | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x | x |