-- Builds item at position in direction
-- example usage build({-51.0,69.0}, "stone-furnace", defines.direction.north)

local function build(p, position, item, direction)

    clog("Info: called build() function")
	-- Check if we have the item
	if p.get_item_count(item) == 0 then
        clog("Error: not enough items in player inventory to build item")
		return false
	end

	-- Check if we can actually place the item at this tile
	local canplace = p.can_place_entity{name = item, position = position, direction = direction}
	local asm = false

	if canplace then
		canplace = p.surface.can_fast_replace{name = item, position = position, direction = direction, force = "player"}
		if canplace then
			asm = p.surface.create_entity{name = item, position = position, direction = direction, force="player", fast_replace=true, player=p}
		else
			asm = p.surface.create_entity{name = item, position = position, direction = direction, force="player"}
		end
	else
        clog("Error: cannot build item at position")
		return false
	end
	if asm then
		p.remove_item({name = item, count = 1})
	end

    clog("Info: successfully built item at position")
	return true
end
