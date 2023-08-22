local games = require "game.game_logic.games"


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
function level:new(stage, character, game_background, music_set, game_prototype, game_data)

    local new_level = {}
    setmetatable(new_level, self)

    new_level.stage = stage
    new_level.character = character
    new_level.game_background = game_background
    new_level.music_set = music_set

    new_level.game = games[game_prototype]:new(game_data)

    new_level.level_manager = level_manager

    return new_level

end

function level:handle_events(key)
    self.game:handle_events(key)
end

function level:update(dt)
    self.character:update_animations()
    self.stage:update_animations()
    self.game:update(dt)
end




return level
