# API commands
Interacting with factorio is exposed via a custom API. The primitive commands are 

## bot
- `move(x,y)`
- `build(x,y,building,direction)`
- `mine(x,y)` 
- `put(x,y,item)`
- `take(x,y,item)`
- `craft(item)`
- `chat(message)`

## bot.inventory

- `read_inventory()`
- `have_item()`

## bot.surroundings 

- `find_closest_building(building)`
- `find_ore_patch()`