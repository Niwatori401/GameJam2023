local character = require("game.character")
local data = require("data")
local level = require("game.level")
local sprite = require("graphic.sprite")
local render_layers = require("graphic.render_layer")
local stage = require("game.stage")

require("utility")


local level_manager = {}


function level_manager:load_level(name)
    --load graphics into here
    local new_level = {}



    -- -- Load bobbles
    -- do
    --     local text = utility.load_text("data/" .. name .. "/game/bobble/bobble_info.txt")
    --     for i = 1, #text do
    --         local line = text[i]
    --         local drawable = utility.load_image("data/" .. name .. "/game/bobble/" .. line .. ".png")
    --         local sprite = sprite.make_sprite(drawable, 0, 0, 1, 1, render_layer.BOBBLES, 0, color.COLOR_WHITE)
    --         table.insert(new_sprites.bobbles, sprite)
    --     end
    -- end

    -- -- Load game_bg
    -- do
    --     local drawable = utility.load_image("data/" .. name .. "/game/game_bg.png")
    --     local sprite = sprite.make_sprite(drawable, 0, 0, 1, 1, render_layer.STAGE_BG, 0, color.COLOR_WHITE)
    --     table.insert(new_sprites.stage_bg, sprite)
    -- end



    -- Load stage
    do
        local drawable = utility.load_image("data/" .. name .. "/stage/stage_bg.png")
        local sprite = sprite:new(drawable, 0, 0, 1, 1, render_layers.STAGE_BG, 0, data.color.COLOR_WHITE)
        new_level.stage = stage:new(sprite)
    end


    -- Load character images
    do
        local text = utility.load_text("data/" .. name .. "/character/character_stage_info.txt")
        images = {}
        stages = {}

        for i = 1, #text do
            local stage_number_value = text[i]
            table.insert(stages, stage_number_value)

            local drawable = utility.load_image("data/" .. name .. "/character/" .. stage_number_value .. ".png")
            table.insert(images, drawable)

        end

        local sprite = sprite:new(images[1], 0, 0, 1, 1, render_layers.CHARACTERS, 0, data.color.COLOR_WHITE)

        new_level.character = character:new(nil, sprite, images, stages, nil)
    end

    level_manager.cur_level = level:new(new_level.stage, new_level.character, nil, nil, nil)

end


return level_manager
