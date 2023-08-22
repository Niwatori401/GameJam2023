local game = require("game.game_logic.game")



local game_main_menu = {}
setmetatable(game_main_menu, {__index = game})


function game_main_menu:new(data)
    local new_game = setmetatable({}, {__index = self})

    new_game.action_set = action_set:new()

    new_game.action_set:add_key_action("right", function (level)
        -- cycle forward in list
    end)

    new_game.action_set:add_key_action("left", function (level)
        -- cycle back in list
    end)

    new_game.action_set:add_key_action("return", function (level)
        -- Select current selection and load it
    end)

    new_game.action_set:add_key_action("escape", function (level)
        -- Exit level
    end)

end


function game_main_menu:draw()

end

function game_main_menu:handle_events(key)

end




return game_main_menu
