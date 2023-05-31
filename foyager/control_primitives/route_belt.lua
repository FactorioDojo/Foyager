function route_belt(source, destination)
    -- Check if arguments are valid
    if type(source) ~= 'table' or type(destination) ~= 'table' then
        clog("Invalid arguments. 'source' and 'destination' should be tables.")
        return false
    end

    -- Check if the player exists
    local player = game.players[1]
    if not player then
        clog("Player does not exist.")
        return false
    end

    -- Check if the player has a yellow belt in inventory
    if not player.get_item_count("transport-belt") > 0 then
        clog("Player does not have a yellow transport belt in inventory.")
        return false
    end

    -- Check if source and destination are within map bounds
    local surface = player.surface
    if not surface.is_chunk_generated(source) or not surface.is_chunk_generated(destination) then
        clog("Source or destination is out of map bounds.")
        return false
    end

    -- Use pathfinding to get a path from source to destination
    local path = surface.find_path(source, destination, {low_priority = false})

    -- Check if a path was found
    if not path then
        clog("Could not find a path from source to destination.")
        return false
    end

    -- Loop over the path, placing a belt on each tile
    for _, waypoint in pairs(path.waypoints) do
        local position = {x = waypoint.position.x, y = waypoint.position.y}
        local direction = waypoint.direction
        if not surface.create_entity({name = "transport-belt", position = position, direction = direction, force = player.force}) then
            clog("Failed to place belt at position " .. position.x .. "," .. position.y)
            return false
        end
    end

    -- If belt placement was successful, return true
    return true
end