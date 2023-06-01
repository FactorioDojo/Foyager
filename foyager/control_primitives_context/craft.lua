-- Handcraft one or more of a recipe
-- craft(8, "stone-furnace")
local function craft(count, recipe)
    clog("Info: called craft() function")
    if count <= 0 then
        clog("Error: craft count must be >= 0")
        return false
    end

	amt = game.players[1].begin_crafting{recipe = recipe, count = count}
    if amt ~= count then
        clog("Warning: tried to craft " .. count .. " items, but could only craft " .. amt)
        return true
    end

    clog("Info: successfully crafted " .. cout .. " item")
	return true
end