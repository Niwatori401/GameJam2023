local games = require "game.game_logic.games"
local action_set = require("game.action_set")

---@class level
local level = {}
level.__index = level

---comment
---@param stage stage
---@param character character
---@param game_background sprite
---@param music_set table table of music
---@param game_prototype string name of entry in games.lua
---@param game_data table collection of misc data for use by the game class defined by game_prototype
---@return level
function level:new(stage, character, game_background, music_set, game_prototype, game_data, level_manager)

    local new_level = {}
    setmetatable(new_level, self)

    new_level.stage = stage
    new_level.character = character
    new_level.game_background = game_background
    new_level.music_set = music_set
    new_level.action_set = action_set:new()
    new_level.action_set:add_key_action("return", function (level)
        level:transition_out()
    end)

    new_level.flags = {}
    new_level.flags.is_leaving = false

    new_level.game = games[game_prototype]:new(game_data)
    new_level.level_manager = level_manager

    new_level.stage:animation_fade_in(0.5)

    new_level.level_manager = level_manager

    return new_level

end


function level:handle_events(key)
    self.action_set:do_all_applicable_actions(key, self)
    self.game:handle_events(key)
end

function level:update(dt)
    self.character:update_animations()
    self.stage:update_animations()
    self.game:update(dt)

    if self.flags.is_leaving then
        self.flags.leaving_progress = self.flags.leaving_progress - dt
        if self.flags.leaving_progress <= 0 then
            self.level_manager:load_level("texas")
        end
    end
end

function level:transition_out()

    if not self.flags.is_leaving then
        self.flags.leaving_progress = 0.5
        self.flags.is_leaving = true
        self.stage:animation_fade_out(0.5)
    end
end

function level:transition_in()
    self.stage:animation_fade_in(0.5)
end

return level
