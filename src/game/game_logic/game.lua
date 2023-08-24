local action_set = require("game.action_set")


local game = {}

function game:new(data)
    local new_game = setmetatable({}, {__index = game})

    new_game.action_set = action_set:new()

    return new_game
end

function game:update()

end

function game:draw()

end

function game:handle_input()

end

function game:handle_events(key)

end




return game
