character_is_moving = false
path_index = 1
path = nil

-- Determines which direction the character should go.
local function get_direction(start_position, end_position)
    local angle = math.atan2(end_position.y - start_position.y, start_position.x - end_position.x)

    -- Given a circle representing the angles, it is divided into eight octants representing the cardinal directions.
    local octant = (angle + math.pi) / (2 * math.pi) * 8 + 0.5

    if octant < 1 then
        return defines.direction.east
    elseif octant < 2 then
        return defines.direction.northeast
    elseif octant < 3 then
        return defines.direction.north
    elseif octant < 4 then
        return defines.direction.northwest
    elseif octant < 5 then
        return defines.direction.west
    elseif octant < 6 then
        return defines.direction.southwest
    elseif octant < 7 then
        return defines.direction.south
    else
        return defines.direction.southeast
    end
end

function positions_approximately_equal(a, b)
    return math.abs(a.x - b.x) < 0.25 and math.abs(a.y - b.y) < 0.25
end

-- Requests a path when the map is clicked.
function move(x,y)
    local surface = game.get_surface("nauvis")
    local character = game.get_player(1).character
    local position = {x = x, y = y}
    local collision_mask = {
      "player-layer",
      "train-layer",
      "consider-tile-transitions",
      "water-tile",
      "object-layer"
  }

    --
    t = character.bounding_box
    
    --probable reason for pathing over water is collision masks.
    --follow this link for collision masks https://wiki.factorio.com/Types/CollisionMask

    pos = character.position
    local bbox ={{pos.x - 0.5, pos.y - 0.5},{pos.x + 0.5, pos.y + 0.5}}
    local bbox2 = {{-0.5,-0.5},{0.5,0.5}}
    surface.request_path{
        bounding_box = bbox2,
        collision_mask = {"water-tile"},
        start = character.position,
        goal = position,
        force = "player",
        radius = 3.0,
        path_resolution_modifier = 0
    }
  end

-- Initializes the movement process when the path is received.
script.on_event(defines.events.on_script_path_request_finished, function (event)
    if event.path then
        character_is_moving = true
        path = event.path
        path_index = 1
        game.get_player(1).print(#path)
    else 
        game.players[1].print("No path found")
    end
end)

-- Moves the character.
script.on_event(defines.events.on_tick, function (event)
    local character = game.get_player(1).character
    if character_is_moving and path ~= nil then
        if positions_approximately_equal(character.position, path[path_index].position) then
            -- waypoint reached
            path_index = path_index + 1  -- select the next waypoint
        end

        if path_index == #path then
            character_is_moving = false
            path_index = 1
        else
            -- move the character for one tick
            game.get_player(1).walking_state = {
                walking = true,
                direction = get_direction(character.position, path[path_index].position)
            }
        end
    end
end)

remote.add_interface("primitives", {
  move = move,
})
