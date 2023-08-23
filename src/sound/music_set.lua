local animation = require "graphic.animation"
local data      = require "data"


---@class music_set
music_set = {}

function music_set:new(stages, audio)

    local new_music = setmetatable({}, {__index = music_set})

    new_music.stages = stages
    new_music.audio = audio
    new_music.volume = 1
    new_music.speed = 1
    new_music.pitch = 1
    new_music.cur_stage_index = 1
    new_music.animation = nil

    return new_music

end


function music_set:play_stage(stage_number)

    local curtime = self.audio[self.cur_stage_index]:tell()
    self.audio[self.cur_stage_index]:stop()
    self.cur_stage_index = stage_number
    self.audio[self.cur_stage_index]:seek(curtime)
    self.audio[self.cur_stage_index]:play()
end

function music_set:update_audio()
    if self.audio[self.cur_stage_index] == nil then
        return
    end

    if self.animation ~= nil then
        self[self.animation.property_to_animate] = self.animation:increment_animation()
    end

    self.audio[self.cur_stage_index]:setVolume(self.volume)
    --self.audio[self.cur_stage_index]:setPitch(self.pitch)
    --self.audio[self.cur_stage_index]:setSpeed(self.speed)
end

function music_set:change_speed(speed, duration)
    self.animation = animation:new(self.speed, speed, data.game.game_time, duration, animation.scheme_linear_interpolate, "speed")
end

function music_set:fade_in(duration)
    self.animation = animation:new(0, 1, data.game.game_time, duration, animation.scheme_linear_interpolate, "volume")
end

function music_set:fade_out()
    self.animation = animation:new(1, 0, data.game.game_time, duration, animation.scheme_linear_interpolate, "volume")
end


return music_set

