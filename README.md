# FactorioAgent

This project is an attempt to create autonomous agents for the game factorio. More details can be found in the `foyager` and `bpsearch` folders respectively.


# foyager

This agent is heavily based on the [Voyager agent](https://github.com/MineDojo/Voyager) made for minecraft. We have repurposed it to play factorio. Like Voyager, the agent consists of three key components: 1) an automatic curriculum that maximizes exploration, 2) an ever-growing skill library of executable code for storing and retrieving complex behaviors, and 3) a new iterative prompting mechanism that incorporates environment feedback, execution errors, and self-verification for program improvement.

The agent writes the programs using the native factorio lua API, which are loaded and executed during runtime.

# bpsearch

This agent conducts an automatic search of blueprints in an effort to find the most efficient blueprint given a set of constraints. This agent is not developed.

## Contributing

Contributions are welcome.

## TODO

- Run in interactive mode w/ text interface