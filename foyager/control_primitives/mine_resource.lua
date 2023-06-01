function mine_resource(ore_type, quantity)
    -- Check if arguments are valid
    if type(ore_type) ~= 'string' or type(quantity) ~= 'number' then
        clog("Invalid arguments. 'ore_type' should be a string and 'quantity' should be a number.")
        return false
    end

  
    -- Check if the ore type exists
    if not resource then
        clog("No resource of type " .. ore_type .. " found.")
        return false
    end

    local player = game.players[1]

    -- Check if the player is in a valid state
    if not player.character or player.character.mining_state.mining then
        clog("Player is not in a valid state for mining.")
        return false
    end

    -- Find nearest ore entity
    local position = player.character.position
    local surface = player.surface
    local resource_position = find_nearest_ore(surface, position, ore_type)

    -- Move to ore position
    await move(resource_position)

    -- Mining ore
    await mine(resouce_position, quantity)

    -- If the mining process was successful, return true
    return true
end

return mine_resource