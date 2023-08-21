

---@class music_set
music_set = {}
music_set.__index = music_set


function music_set:new(stages, audio)

    local new_music = {}
    setmetatable(new_music, music_set)

    new_music.stages = stages
    new_music.audio = audio
    new_music.volume = 1
    new_music.speed = 1
    new_music.pitch = 1
    new_music.cur_stage_index = 0
    new_music.animations = {}
    return new_music

end


function music_set:play_stage(stage_number)


end

function music_set:update_audio()
    self.audio[self.cur_stage_index]:setVolume(self.volume)
    self.audio[self.cur_stage_index]:setPitch(self.pitch)
    self.audio[self.cur_stage_index]:setSpeed(self.volume)
end

function music_set:fade_in()


end

function music_set:fade_out()

end

function music_set:play_next_stage()


end



function music_set:play_previous_stage()

end


return music_set

