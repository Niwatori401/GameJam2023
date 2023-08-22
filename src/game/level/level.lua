local action_set = require("src.game.level.level_action_set")


---@class level
local level = {}
level.__index = level

---comment
---@param stage stage
---@param character character
---@param game_background sprite
---@param bobble_set table array of bobbles
---@param music_set table table of music
---@return level
function level:new(stage, character, game_background, bobble_set, music_set, level_manager)

    local new_level = {}
    setmetatable(new_level, self)

    new_level.stage = stage
    new_level.character = character
    new_level.game_background = game_background
    new_level.bobble_set = bobble_set
    new_level.music_set = music_set
    new_level.action_set = action_set:new()
    new_level.level_manager = level_manager

    new_level.action_set:add_key_action("r", function (level)
        level.level_manager:load_level("_main_menu")
    end)

    return new_level

end




return level
