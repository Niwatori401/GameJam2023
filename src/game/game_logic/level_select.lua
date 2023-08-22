local action_set = require("game.level.action_set")
local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
require("utility")


local game_level_select = {}
setmetatable(game_level_select, {__index = game})


function game_level_select:new(game_data)
    local new_game = setmetatable({}, {__index = game_level_select})



    local map_info = utility.parse_info(game_data["map_info"])
    local level_info = utility.parse_info(game_data["level_info"])

    local level_data = {}
    local level_id = 1

    for filename, levelpos in pairs(map_info) do
        local new_level = {}
        new_level.filename = filename
        new_level.title = level_info[filename]
        local x, y = string.match(levelpos, "(%d+) (%d+)")
        new_level.pos_x = x
        new_level.pos_y = y

        level_data[level_id] = new_level

        level_id = level_id + 1
    end

    new_game.selector_sprite = sprite:new(
        game_data.select, 0, 0, 1, 1, render_layer.EFFECTS, 0, data.color.COLOR_WHITE)

    new_game.currently_selected_index = 1

    new_game.level_data = level_data

    new_game.action_set = action_set:new()

    new_game.action_set:add_key_action("left", function (game)
        game.currently_selected_index = ((game.currently_selected_index) % #game.level_data) + 1
    end)


    new_game.action_set:add_key_action("right", function (game)
        game.currently_selected_index = ((game.currently_selected_index - 2) % #game.level_data) + 1
    end)


    new_game.action_set:add_key_action("return", function (game)

    end)


    new_game.action_set:add_key_action("escape", function (game)

    end)

    return new_game

end

function game_level_select:update(dt)

    local level_data = self.level_data[self.currently_selected_index]

    self.selector_sprite.x = level_data.pos_x
    self.selector_sprite.y = level_data.pos_y
end


function game_level_select:draw(layer)
    local s = self.selector_sprite

    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            s.x_scale,
            s.y_scale,
            s.image:getWidth() / 2,
            s.image:getHeight() / 2
        )
    end
end

function game_level_select:handle_events(key)
    self.action_set:do_all_applicable_actions(key, self)
end



return game_level_select
