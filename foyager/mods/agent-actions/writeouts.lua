-- This function writes out the player's available recipes to a file
function writeout_recipes()
    -- Fetch the player's force (which tracks their available technologies and recipes)
    local player_force = game.player.force

    -- Create a table to store the recipe data
    local recipe_data = {}

    -- Iterate through the player's available recipes
    for name, recipe in pairs(player_force.recipes) do
        if recipe.enabled then
            -- If the recipe is available to the player, record its name and ingredients
            local ingredients = {}
            for _, ingredient in pairs(recipe.ingredients) do
                table.insert(ingredients, {ingredient_name = ingredient.name, ingredient_amount = ingredient.amount})
            end

            -- Find all assemblers that can craft this recipe
            local assemblers = {}
            for _, entity in pairs(game.entity_prototypes) do
                if entity.type == "assembling-machine" and entity.crafting_categories[recipe.category] then
                    table.insert(assemblers, entity.name)
                end
            end

            -- Add the recipe to the recipe data
            table.insert(recipe_data, {recipe_name = name, ingredients = ingredients, assemblers = assemblers})
        end
    end

    -- Convert the recipe data to JSON format
    local json_data = game.table_to_json(recipe_data)

    -- Write the JSON data to a file
    local filename = "recipes.json"
    game.write_file(filename, json_data, false)

    -- Notify the player that the recipe data has been written
    game.player.print("Available recipe data has been written to " .. filename)
end


function WriteOutInventory()
    -- Get the player's main inventory
    local player_inventory = game.player.get_main_inventory()

    -- Create a table to store the inventory data
    local inventory_data = {}

    -- Iterate through the player's inventory and record item names and quantities
    for name, count in pairs(player_inventory.get_contents()) do
        table.insert(inventory_data, {item_name = name, item_count = count})
    end

    -- Convert the inventory data to JSON format
    local json_data = game.table_to_json(inventory_data)

    -- Write the JSON data to a file
    local filename = "inventory_data.json"
    game.write_file(filename, json_data, false)

    -- Notify the player that the inventory data has been written
    game.player.print("Inventory data has been written to " .. filename)
end


function writeout_filtered_entities(entity_type)
	local player_id = 1  -- Specify the ID of the player whose position you want to get
    local player = game.players[player_id]  -- Get the player instance using the player's ID
    local player_position = player.character.position

    local surface = game.surfaces['nauvis']
    local chunk_x = player_position.x -  100
    local chunk_y = player_position.y - 100
    local chunk_xend = player_position.x + 100
    local chunk_yend = player_position.y + 100

    local area={left_top={x=chunk_x, y=chunk_y}, right_bottom={x=chunk_xend, y=chunk_yend}}

    -- Create a table to store the entity data
    local entity_data = {}

    -- Find all entities in the defined area of the specified type
    local entities = surface.find_entities_filtered({area = area, type = entity_type})
    for _, entity in ipairs(entities) do
        local position = entity.position
        local entity_type = entity.name
        local contents = nil

        -- If the entity has an inventory, get its contents
        if entity.get_inventory(defines.inventory.chest) then
            contents = entity.get_inventory(defines.inventory.chest).get_contents()
        end

        -- If the entity is a transport belt, get its contents
        if entity.type == "transport-belt" then
            contents = entity.get_transport_line(1).get_contents()  -- get contents of the first transport line
            for item, count in pairs(entity.get_transport_line(2).get_contents()) do  -- get contents of the second transport line
                if contents[item] then
                    contents[item] = contents[item] + count
                else
                    contents[item] = count
                end
            end
        end

        table.insert(entity_data, {entity_type = entity_type, position = position, contents = contents})
    end

       -- Convert the inventory data to JSON format
	   local json_data = game.table_to_json(entity_data)

	   -- Write the JSON data to a file
	   local filename = entity_type .. "_data.json"
	   game.write_file(filename, json_data, false)
   
	   -- Notify the player that the inventory data has been written
	   game.players[1].print("Inventory data has been written to " .. filename)
end

-- Define a remote interface to expose the functions
remote.add_interface("writeouts", {
	writeout_filtered_entities=writeout_filtered_entities,
	writeout_inventory = WriteOutInventory,
	writeout_recipes = writeout_recipes
})

return writeouts