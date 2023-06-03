function smeltOneIronPlate()
    local player = game.get_player(1)
    local nearest_furnace_array = game.surfaces[1].find_entities_filtered{position = player.character.position, radius=20, limit=1, name = {"stone-furnace"}}

    -- Check if there is a furnace nearby
    if nearest_furnace_array == nil or #nearest_furnace_array == 0 then
        clog("No furnace in the vicinity")
        return
    end

    local nearest_furnace = nearest_furnace_array[1] -- get the first furnace from the array
    clog(serpent.block(nearest_furnace))

    local coal_stack = player.get_main_inventory().find_item_stack('coal')
    local iron_ore_stack = player.get_main_inventory().find_item_stack('iron-ore')

    if coal_stack == nil then
        clog("No coal in player's inventory")
        return
    end

    if iron_ore_stack == nil then
        clog("No iron-ore in player's inventory")
        return
    end

    -- Calculate a nearby point and move player there instead of directly on the furnace
    local new_position = {x = nearest_furnace.position.x + 2, y = nearest_furnace.position.y + 2} -- just an example, you may need to calculate a valid position near the furnace
    move(new_position)

    -- Insert coal into the fuel slot (slot 1)
    if nearest_furnace.get_inventory(1).can_insert{name='coal', count=1} then
        nearest_furnace.get_inventory(1).insert{name='coal', count=1}
    else
        clog("Furnace does not accept fuel")
        return
    end

    -- Insert iron ore into the source slot (slot 2)
    if nearest_furnace.get_inventory(2).can_insert{name='iron-ore', count=1} then
        nearest_furnace.get_inventory(2).insert{name='iron-ore', count=1}
    else
        clog("Furnace does not accept items for smelting")
        return
    end

    clog("Smelting process started")

    -- Wait for the smelting process to complete and then take the smelted iron plate
    -- Assuming that the smelting process takes 3.5 seconds
    game.tick_paused = true
    game.ticks_to_run = (3.5 * 60)
    game.tick_paused = false

    -- Take the smelted iron plate from the result slot (slot 3)
    local result = nearest_furnace.get_inventory(3)[1]
    if result and result.valid then
        if player.get_main_inventory().can_insert(result) then
            local count = player.get_main_inventory().insert(result)
            nearest_furnace.get_inventory(3).remove({name=result.name, count=count})
            clog("Smelting process finished and the result is taken")
        else
            clog("Player's inventory is full, couldn't take the result")
        end
    else
        clog("Furnace does not produce a result")
    end
end

return smeltOneIronPlate
   
