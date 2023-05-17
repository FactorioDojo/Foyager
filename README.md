# FactorioAgent

This project is an attempt to create an autonomous agent to play the game factorio. Currently, we are using API calls to OpenAIs text-davinci-3 model to plan and execute tasks. We are exploring other methods such as creating an interactive human/LLM dialogue to aid the process.


## Requirements
- Factorio
- Docker

## Installing

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

You will need an API key from OpenAI. You may get one of those [here](https://platform.openai.com/). Create a file in the `agent` folder named `secrets.py` and store your API key there:

```
API_KEY_OPENAI = 123
```

The agent is located in the `agent` folder and can be run with:

```
python main.py
```

## Contributing

Contributions are welcome.

## TODO

- Run in interactive mode w/ text interface