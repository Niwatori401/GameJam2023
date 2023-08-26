local action_set = require("game.action_set")
local animation = require("graphic.animation")
local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
require("utility")


local game_main_menu = {}
setmetatable(game_main_menu, {__index = game})


function game_main_menu:new(game_data, lvl)
    local new_game = setmetatable({}, {__index = game_main_menu})

    new_game.level = lvl
    new_game.action_set = action_set:new()
    new_game.font_size_factor = 1
    local game_info = utility.parse_info(game_data["game_info"])


    new_game.next_level = game_info.next_level

    new_game.elapsed_time = 0


    new_game.action_set:add_key_action("return", function (game)
        game.level.exit_status = "unconditional_load"
        game.level.payload = {level_to_load = new_game.next_level}
        game.level:transition_out()
    end)

    return new_game
end


function game_main_menu:update(dt)
    self.elapsed_time = (self.elapsed_time + dt) % (2 * math.pi)
    self.font_size_factor = math.sin(self.elapsed_time)
end

function game_main_menu:draw(layer)

    if layer == render_layer.EFFECTS then
        local font_scale = 1.3 + 0.2 * self.font_size_factor
        local drop_shadow_offset = 1
        local max_width = 400
        local x_pos = data.window.SCREEN_X / 2
        local y_pos = 2 * data.window.SCREEN_Y / 3
        -- Drop shadow
        love.graphics.setColor(data.color.COLOR_WHITE)
        love.graphics.printf(
            "Press ENTER to play!",
            data.font.fonts["ArchitectsDaughter18"],
            x_pos + drop_shadow_offset,
            y_pos + drop_shadow_offset,
            max_width,
            "center",
            0,
            font_scale,
            font_scale,
            max_width / 2,
            0)

        -- Top text
        love.graphics.setColor(data.color.COLOR_BLACK)
        love.graphics.printf(
            "Press ENTER to play!",
            data.font.fonts["ArchitectsDaughter18"],
            x_pos,
            y_pos,
            max_width,
            "center",
            0,
            font_scale,
            font_scale,
            max_width / 2,
            0)
    end
end

function game_main_menu:handle_events(key)
    self.action_set:do_all_applicable_actions(key, {self})
end



return game_main_menu
