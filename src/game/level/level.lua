local action_set = require("game.action_set")
local data = require("data")
local games = require("game.game_logic.games")
local request = require("game.state.request")

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
---@param name string
---@return level
function level:new(stage, character, game_background, music_set, game_prototype, game_data, name)

    local new_level = {}
    setmetatable(new_level, level)

    new_level.name = name
    new_level.stage = stage

    new_level.character = character
    new_level.game_background = game_background
    new_level.music_set = music_set


    new_level.flags = {}
    new_level.flags.is_leaving = false

    new_level.game = games[game_prototype]:new(game_data)
    new_level.game.level = new_level

    new_level.stage:animation_fade_in(0.5)
    new_level.character:animation_enter_screen()

    new_level.music_set:fade_in(2)
    love.audio.stop()
    new_level.music_set:play_stage(1)

    new_level.exit_status = "game_success"
    new_level.payload = nil

    return new_level

end


function level:handle_events(key)
    self.game:handle_events(key)
end

function level:update(dt)
    self.character:update_animations()
    self.stage:update_animations()
    self.game:update(dt)
    self.music_set:update_audio()

    if self.flags.is_leaving then
        self.flags.leaving_progress = self.flags.leaving_progress - dt
        if self.flags.leaving_progress <= 0 then
            data.game.machine:transition_state(request:new(self, self.exit_status, self.payload))
        end
    end
end

function level:transition_out()

    if not self.flags.is_leaving then
        self.flags.leaving_progress = 1.5
        self.flags.is_leaving = true
        self.character:animation_leave_screen()
        self.stage:animation_fade_out(1)
    end
end

function level:transition_in()
    self.stage:animation_fade_in(0.5)
end

return level
