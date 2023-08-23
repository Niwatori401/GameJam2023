local game = require("game.game_logic.game")
local action_set = require("game.action_set")

local game_puzzle_bobble = {}

setmetatable(game_puzzle_bobble, {__index = game})

function game_puzzle_bobble:new(game_data)
    local new_game = setmetatable({}, {__index = game_puzzle_bobble})


    new_game.action_set = action_set:new()

    new_game.action_set:add_key_action("left", function (game)
        -- play game
    end)


    new_game.action_set:add_key_action("right", function (game)
        -- play game
    end)


    new_game.action_set:add_key_action("escape", function (game)
        game.level.exit_status = "abort_level"
        game.level:transition_out()
    end)

    return new_game

end

function game_puzzle_bobble:update(dt)

    -- local level_data = self.level_data[self.currently_selected_index]
    -- self.selector_sprite.x = level_data.pos_x
    -- self.selector_sprite.y = level_data.pos_y
    -- self.selector_sprite.rotation = self.selector_sprite.animations[1]:increment_animation(cur_time)
end


function game_puzzle_bobble:draw(layer)


end

function game_puzzle_bobble:handle_events(key)
    self.action_set:do_all_applicable_actions(key, self)
end



return game_puzzle_bobble
