local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
local action_set = require("game.action_set")

local game_puzzle_bobble = {}

setmetatable(game_puzzle_bobble, {__index = game})

function game_puzzle_bobble:new(game_data)
    local new_game = setmetatable({}, {__index = game_puzzle_bobble})

    self:_make_game_bg_sprite(game_data)
    self:_define_level_actions()

    return new_game

end

--#region game interface functions

function game_puzzle_bobble:update(dt)


end


function game_puzzle_bobble:draw(layer)

    --new_game.game_bg
    local s = self.game_bg

    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            s.x_scale,
            s.y_scale
        )
    end
end

function game_puzzle_bobble:handle_events(key)
    self.action_set:do_all_applicable_actions(key, self)
end

--#endregion

--#region game logic functions

function game_puzzle_bobble:_get_next_bobble_row()

end

function game_puzzle_bobble:_pop_appropriate_bobbles()

end

--#endregion

--#region constructor helpers

--- Mutates class, returns nothing
function game_puzzle_bobble:_define_bobbles(game_data)

end


--- Mutates class, returns nothing
function game_puzzle_bobble:_define_grid(game_data)

end


--- Mutates class, returns nothing
function game_puzzle_bobble:_define_level_actions()
    self.action_set = action_set:new()

    self.action_set:add_key_action("left", function (game)
        -- play game
    end)


    self.action_set:add_key_action("right", function (game)
        -- play game
    end)


    self.action_set:add_key_action("escape", function (game)
        game.level.exit_status = "abort_level"
        game.level:transition_out()
    end)
end

--- Mutates class, returns nothing
function game_puzzle_bobble:_make_game_bg_sprite(game_data)
    local game_width = 380
    local game_height = 540
    local game_x = 610
    local game_y = 15
    local game_bg_image = game_data["game_bg"]
    self.game_bg = sprite:new(
        game_bg_image,
        game_x,
        game_y,
        game_width / game_bg_image:getWidth(),
        game_height / game_bg_image:getHeight(),
        render_layer.GAME_BG,
        0,
        data.color.COLOR_WHITE)
end

--#endregion


return game_puzzle_bobble
