local action_set = require("game.level.action_set")


local game = {}

function game:new(data)
    local new_game = setmetatable({}, {__index = game})

    new_game.action_set = action_set:new()

    new_game.action_set:add_key_action("r", function (level)
        --level.level_manager:load_level("_main_menu")
    end)

end

function game:update()

end

function game:draw()

end

function game:handle_events(key)

end




return game
