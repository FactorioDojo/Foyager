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

## Factorio API  

### Primitive commands
Interacting with factorio is exposed via a custom API. The primitive commands are 
- `move(x,y)`
- `build(x,y,building,direction)`
- `mine(x,y)` 
- `put(x,y,item)`
- `take(x,y,item)`
- `craft(item)`
- `read_environment()`
- `read_inventory()`
 
All agents may use these commands in pursuit of their objective. 

### Abstract commands

Due to the difficulty in the level of attention to detail necessary to play the game with only these commands, we also provide an abstracted API. These abstract API commands act as a crutch for the agent, taking care of the specific implementations of general tasks. The abstract commands are:

- `gather_ore(ore_type)`
- `craft_item(item)`
- `build_forge(x,y)`
- `build_mine(x,y)`
- more

### API access levels

There are 5 levels of API access. This allows us to test the agent against different standards.

Level 1: Only primitive commands
- `move(x,y)`
- `build(x,y,building,direction)`
- `mine(x,y)` 
- `put(x,y,item)`
- `take(x,y,item)`
- `craft(item)`
- `read_environment()`
- `read_inventory()`
 
Level 2: ...

Level 3: ...

Level 4: ...

Level 5: ...

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
