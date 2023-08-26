local action_set = require("game.action_set")
local animation = require("graphic.animation")
local data = require("data")
local game = require("game.game_logic.game")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")
require("utility")


local game_splash = {}
setmetatable(game_splash, {__index = game})


function game_splash:new(game_data, lvl)
    local new_game = setmetatable({}, {__index = game_splash})

    new_game.level = lvl
    new_game.action_set = action_set:new()

    local game_info = utility.parse_info(game_data["splash_data"])


    new_game.next_level = game_info.next_level
    new_game.duration = tonumber(game_info.duration)

    new_game.elapsed_time = 0


    new_game.action_set:add_key_action("return", function (game)
        game.level.exit_status = "unconditional_load"
        game.level.payload = {level_to_load = new_game.next_level}
        game.level:transition_out()
    end)

    return new_game
end



function game_splash:update(dt)
    self.elapsed_time = self.elapsed_time + dt

    if self.elapsed_time >= self.duration then
        self.level.exit_status = "unconditional_load"
        self.level.payload = {level_to_load = self.next_level}
        self.level:transition_out()
    end
end

function game_splash:draw(layer)

end

function game_splash:handle_events(key)
    self.action_set:do_all_applicable_actions(key, {self})
end



return game_splash
