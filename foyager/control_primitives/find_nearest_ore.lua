function find_nearest_ore(surface, position, ore_type)
    -- set initial search radius
    local radius = 1

    -- loop until we find an ore entity of the right type or we exceed the maximum search radius
    while radius <= 1000 do
        local entities = surface.find_entities_filtered{area = {{position.x - radius, position.y - radius}, {position.x + radius, position.y + radius}}, type = "resource"}

        for _, entity in ipairs(entities) do
            if entity.prototype.resource_category == 'basic-solid' and entity.name == ore_type then
                game.players[1].print(entity.position)
                return entity
            end
        end

        -- increment search radius
        radius = radius + 1
    end

    -- no entity found within maximum search radius
    return nil
end

return find_nearest_ore