local action_set = require("game.action_set")
local animation = require("graphic.animation")
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

    new_game.gun_shot = game_data.gun_shot
    new_game.cock = game_data.cock

    new_game.selector_sprite = sprite:new(
        game_data.select, 0, 0, 1, 1, render_layer.GAME_BG, 0, data.color.COLOR_WHITE)

    local revolution_rate = 2
    local seconds_to_animate = 3600

    new_game.selector_sprite:add_animation(
        animation:new(
            0,
            revolution_rate * seconds_to_animate * 2 * math.pi,
            data.game.game_time,
            seconds_to_animate,
            animation.scheme_linear_interpolate,
            "rotation")
    )

    new_game.dot_sprite = sprite:new(
        game_data.dot, 0 ,0, 1, 1, render_layer.GAME_BG, 0, data.color.COLOR_WHITE
    )

    new_game.currently_selected_index = 1

    new_game.level_data = level_data

    new_game.action_set = action_set:new()

    new_game.action_set:add_key_action("left", function (game)
        game.cock:play()
        game.currently_selected_index = ((game.currently_selected_index) % #game.level_data) + 1
    end)


    new_game.action_set:add_key_action("right", function (game)
        game.cock:play()
        game.currently_selected_index = ((game.currently_selected_index - 2) % #game.level_data) + 1
    end)


    new_game.action_set:add_key_action("return", function (game)
        game.gun_shot:play()
        game.level.exit_status = "unconditional_load"
        game.level.payload = {level_to_load = game.level_data[game.currently_selected_index].filename}
        game.level:transition_out()
    end)


    new_game.action_set:add_key_action("escape", function (game)
        game.level.exit_status = "abort_level"
        game.level:transition_out()
    end)

    return new_game

end

function game_level_select:update(dt)

    local level_data = self.level_data[self.currently_selected_index]

    self.selector_sprite.x = level_data.pos_x
    self.selector_sprite.y = level_data.pos_y
    self.selector_sprite.rotation = self.selector_sprite.animations[1]:increment_animation(cur_time)
end


function game_level_select:draw(layer)
    local s = self.selector_sprite
    if layer == render_layer.GAME_BG then
        love.graphics.setColor(data.color.COLOR_WHITE)
        local max_width = 100
        local font_scale = 1.3
        local drop_shadow_offset = 1


        love.graphics.printf(
            self.level_data[self.currently_selected_index].title,
            data.font.fonts["Crosterian"],
            s.x + drop_shadow_offset,
            s.y - 50 + drop_shadow_offset,
            max_width,
            "center",
            0,
            font_scale,
            font_scale,
            max_width / 2,
            0)
        love.graphics.setColor(data.color.COLOR_BLACK)
        love.graphics.printf(
            self.level_data[self.currently_selected_index].title,
            data.font.fonts["Crosterian"],
            s.x,
            s.y - 50,
            max_width,
            "center",
            0,
            font_scale,
            font_scale,
            max_width / 2,
            0)
    end

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

    s = self.dot_sprite

    for _, country_data in pairs(self.level_data) do

        local x = country_data.pos_x
        local y = country_data.pos_y

        if layer == s.layer then
            love.graphics.setColor(s.color)
            love.graphics.draw(
                s.image,
                x,
                y,
                s.rotation,
                s.x_scale,
                s.y_scale,
                s.image:getWidth() / 2,
                s.image:getHeight() / 2
            )
        end
    end


end

function game_level_select:handle_events(key)
    self.action_set:do_all_applicable_actions(key, self)
end



return game_level_select
