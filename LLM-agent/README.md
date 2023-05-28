# LLM-agent

## Overview

(Move this into real docs at some point)

This agent attempts to play factorio using only LLMs. Different language models, prompts and levels of API access are applied and tested in an attempt to achieve specfic tasks.

Agents play on a randomly generated 500x500 square map, with the following conditions:
- No cliffs
- No trees
- No rocks
- No biters
- Water only near spawn position 

## Factorio Interface  

In contrast to Voyager, we use a custom interface to communicate with the factorio environment. In the `interface` folder 

### API commands
Interacting with factorio is exposed via a custom API. The primitive commands are 
- `move(x,y)`
- `build(x,y,building,direction)`
- `mine(x,y)` 
- `put(x,y,item)`
- `take(x,y,item)`
- `craft(item)`
- `chat(message)`
- `read_environment()`
- `read_inventory()`
 

## Prompts

Of particular interest is how the performance of the agent varies according to the prompting method use. We use [microsoft's guidance library](https://github.com/microsoft/guidance) to construct prompts, custom discriminators and other logic.

### Live feedback

We experiment with the ability to input live feedback from a human. (Priority)


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
