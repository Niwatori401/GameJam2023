local character = require("game.character")
local data = require("data")
local level = require("game.level.level")
local music_set = require("sound.music_set")
local sprite = require("graphic.sprite")
local render_layers = require("graphic.render_layer")
local stage = require("game.stage")

require("utility")


local level_manager = {}


function level_manager:load_level(name)

    local new_level = {}


    -- Load all files in the game/ directory and save into big table
    do
        local game_data_file_names = love.filesystem.getDirectoryItems("data/".. name .. "/game")

        local game_data = {}

        for _, filename in pairs(game_data_file_names) do
            local cleaned_name = string.match(filename, "(.+)%..+")
            if string.find(filename, "%.txt") then
                game_data[cleaned_name] = utility.load_text("data/".. name .. "/game/" .. filename)
            elseif string.find(filename, "%.ogg") then
                game_data[cleaned_name] = utility.load_music("data/".. name .. "/game/" .. filename)
            elseif string.find(filename, "%.png") then
                game_data[cleaned_name] = utility.load_image("data/".. name .. "/game/" .. filename)
            end
        end

        new_level.game_data = game_data
    end


    -- Load metadata
    do
        local lines = utility.load_text("data/" .. name .. "/meta")
        local metadata = utility.parse_info(lines)
        new_level.level_prototype = metadata.level_prototype
    end

    -- Load music
    if love.filesystem.getInfo( "data/" .. name .. "/stage/audio/audio_info.txt", "file" ) ~= nil then

        local music = {}
        local stages = {}

        local text = utility.load_text("data/" .. name .. "/stage/audio/audio_info.txt")
        for i = 1, #text do
            local line = text[i]
            local playable = utility.load_music("data/" .. name .. "/stage/audio/" .. line .. ".ogg")
            table.insert(stages, line)
            table.insert(music, playable)
        end

        new_level.music = music_set:new(stages, music)

    else
        new_level.music = music_set:new({1}, {data.defaults.silence})
    end



    -- Load stage
    do
        local drawable = utility.load_image("data/" .. name .. "/stage/stage_bg.png")
        local sprite = sprite:new(drawable, 0, 0, 1, 1, render_layers.STAGE_BG, 0, data.color.COLOR_WHITE)
        new_level.stage = stage:new(sprite)
    end


    -- Load character data
    if love.filesystem.getInfo( "data/" .. name .. "/character/character_stage_info.txt", "file" ) ~= nil then
        local text = utility.load_text("data/" .. name .. "/character/character_stage_info.txt")
        images = {}
        stages = {}
        dialogue = {}

        for i = 1, #text do
            local stage_number_value = text[i]
            table.insert(stages, stage_number_value)

            local dia_instance = utility.load_text("data/" .. name .. "/character/" .. stage_number_value .. ".txt")
            table.insert(dialogue, dia_instance)

            local drawable = utility.load_image("data/" .. name .. "/character/" .. stage_number_value .. ".png")
            table.insert(images, drawable)

        end

        local sprite = sprite:new(images[1], 0, 0, 1, 1, render_layers.CHARACTERS, 0, data.color.COLOR_WHITE)

        new_level.character = character:new(nil, sprite, images, stages, 100, dialogue)
    else
        new_level.character = character:new("", sprite:new(data.defaults.transparent, 0, 0, 0, 0, render_layers.CHARACTERS, 0, data.color.COLOR_CLEAR), {data.defaults.transparent}, {0}, 0, {})
    end

    level_manager.cur_level = level:new(
        new_level.stage,
        new_level.character,
        nil,
        new_level.music,
        new_level.level_prototype,
        new_level.game_data,
        name)

end


return level_manager
