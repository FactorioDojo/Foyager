-- move player to position x,y
-- ex usage, move(0,0)
function move(x,y)
    local surface = game.get_surface("nauvis")
    local character = game.get_player(1).character
    local position = {x = x, y = y}
    local collision_mask = {
      "water-tile",
      "object-layer",
      "player-layer",
      "train-layer",
      "consider-tile-transitions",
  }

    --
    t = character.bounding_box
    
    --probable reason for pathing over water is collision masks.
    --follow this link for collision masks https://wiki.factorio.com/Types/CollisionMask

    pos = character.position
    --game.players[1].print(t.left_top.x .. ", " .. t.left_top.y)
    --game.players[1].print(t.right_bottom.x .. ", " .. t.right_bottom.y)
    local bbox ={{pos.x - 0.5, pos.y - 0.5},{pos.x + 0.5, pos.y + 0.5}}
    local bbox2 = {{-0.5,-0.5},{0.5,0.5}}

    global.path_received = false


    surface.request_path{
        bounding_box = bbox2,
        collision_mask = {"water-tile"},
        start = character.position,
        goal = position,
        force = "player",
        radius = 3.0,
        path_resolution_modifier = 0
    }

    subscribe_on_tick_event(on_tick_move_event)
end