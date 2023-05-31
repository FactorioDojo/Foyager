local moving = true

function move(x, y)
    local player = game.players[1] -- Assuming it's the first player, you can adjust this based on your needs
    local position = {x = x, y = y}
    
    -- Request path with high priority
    local path = player.surface.request_path{
      bounding_box = {{player.position.x, player.position.y}, position},
      force = defines.force.player,
      radius = 1,
      collision_mask = {"player-layer"},
      path_resolution_modifier = 0 -- Use the highest path resolution
    }
  
    -- Start walking if path is valid
    if path then
      player.walking_state = {
        walking = true,
        path = path
      }
    end
  end
  
  -- Event handler to update walking state
  script.on_nth_tick(1, function(event)
    if moving then
        local player = game.players[1] -- Assuming it's the first player, you can adjust this based on your needs
        
        if player.walking_state and player.walking_state.walking then
        player.walking_state.path = player.walking_state.path:sub(2) -- Remove the first position in the path
        if #player.walking_state.path > 0 then
            player.walking_state.destination = player.walking_state.path[1]
        else
            player.walking_state = nil -- Clear walking state if path is completed
            moving = false
        end
        end
    end
  end)
  