local task = {}

-- Move to the Stone patch
task[1] = {"move", {14.4, -3.5}}

-- Use the burner mining drill to mine Stone
task[2] = {"build", {15.4, -3.5}, "burner-mining-drill", defines.direction.east}

-- Wait for the mining to complete
task[3] = {"idle", 100}

-- Take 5 stone (enough for one furnace)
task[4] = {"take", {15.4, -3.5}, "stone", 5, defines.inventory.burner_drill_output}

-- Craft a Stone Furnace
task[5] = {"craft", 1, "stone-furnace"}

-- Move to the Iron patch
task[6] = {"move", {31.5, 23.5}}

-- Use the burner mining drill to mine Iron Ore
task[7] = {"build", {32.5, 23.5}, "burner-mining-drill", defines.direction.east}

-- Wait for the mining to complete
task[8] = {"idle", 100}

-- Take 5 iron ore
task[9] = {"take", {32.5, 23.5}, "iron-ore", 5, defines.inventory.burner_drill_output}

-- Build the Stone Furnace and put iron ore into it
task[10] = {"build", {33.5, 23.5}, "stone-furnace", defines.direction.east}
task[11] = {"put", {33.5, 23.5}, "iron-ore", 5, defines.inventory.furnace_source}

-- Wait for the smelting to complete
task[12] = {"idle", 100}

-- Take the smelted Iron Plates
task[13] = {"take", {33.5, 23.5}, "iron-plate", 2, defines.inventory.furnace_result}

-- Craft an Iron Gear Wheel
task[14] = {"craft", 1, "iron-gear-wheel"}

-- Move to the Copper patch
task[15] = {"move", {61.5, 15.5}}

-- Use the burner mining drill to mine Copper Ore
task[16] = {"build", {62.5, 15.5}, "burner-mining-drill", defines.direction.east}

-- Wait for the mining to complete
task[17] = {"idle", 100}

-- Take 1 copper ore
task[18] = {"take", {62.5, 15.5}, "copper-ore", 1, defines.inventory.burner_drill_output}

-- Move to the Stone Furnace and put the Copper Ore into it
task[19] = {"move", {33.5, 23.5}}
task[20] = {"put", {33.5, 23.5}, "copper-ore", 1, defines.inventory.furnace_source}

-- Wait for the smelting to complete
task[21] = {"idle", 100}

-- Take the smelted Copper Plate
task[22] = {"take", {33.5, 23.5}, "copper-plate", 1, defines.inventory.furnace_result}

-- Finally, craft the red science pack
task[23] = {"craft", 1, "red-science"}

return task
