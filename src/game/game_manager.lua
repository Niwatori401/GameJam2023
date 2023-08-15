require("graphic/sprite_renderer")
require("graphic/sprite")
require("utility")
require("data")

game_manager = {}

game_manager.cur_level = nil

game_manager.init = function ()

end

game_manager.load_level = function (self, name)
    local level = {}

    --load graphics into here
    level.graphics = {}
    local new_sprites = {}
    new_sprites.bobbles = {}
    new_sprites.character = {}
    new_sprites.stage_bg = {}
    new_sprites.game_bg = {}

    -- Load bobbles
    do
        local text = utility.load_text("data/" .. name .. "/game/bobble/bobble_info.txt")
        for i = 1, #text do
            local line = text[i]
            local drawable = utility.load_image("data/" .. name .. "/game/bobble/" .. line .. ".png")
            local sprite = sprite.make_sprite(drawable, 0, 0, 1, 1, sprite_renderer.layers.BOBBLES, 0, color.COLOR_WHITE)
            table.insert(new_sprites.bobbles, sprite)
        end
    end


    -- Load stage_bg
    do
        local drawable = utility.load_image("data/" .. name .. "/stage/stage_bg.png")
        local sprite = sprite.make_sprite(drawable, 0, 0, 1, 1, sprite_renderer.layers.STAGE_BG, 0, color.COLOR_WHITE)
        table.insert(new_sprites.stage_bg, sprite)
    end

    -- Load game_bg
    do
        local drawable = utility.load_image("data/" .. name .. "/game/game_bg.png")
        local sprite = sprite.make_sprite(drawable, 0, 0, 1, 1, sprite_renderer.layers.STAGE_BG, 0, color.COLOR_WHITE)
        table.insert(new_sprites.stage_bg, sprite)
    end

    -- Load character images
    do
        local text = utility.load_text("data/" .. name .. "/character/character_stage_info.txt")
        for i = 1, #text do
            local line = text[i]
            local drawable = utility.load_image("data/" .. name .. "/character/" .. line .. ".png")
            local sprite = sprite.make_sprite(drawable, 0, 0, 1, 1, sprite_renderer.layers.CHARACTERS, 0, color.COLOR_WHITE)

            table.insert(new_sprites.character, sprite)
        end
    end









    sprite_renderer:clear_sprites()

    for _, table in pairs(new_sprites) do
        sprite_renderer:add_sprites(table)
    end

    level.prev_level = game_manager.cur_level
    game_manager.cur_level = level

    return level
end

game_manager.go_to_previous_level = function (self)

end
