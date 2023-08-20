local animation = require("graphic.animation")
local data = require("data")
local character = require("game.character")
local sprite = require("graphic.sprite")


---Responsible for rendering all sprites on screen.
---Layers are defined as follows:
---(1, 2, 3 - Stage Backgrounds, 4, 5 - characters, 6 - game area background, 7, 8 - Bobbles, 9)
---@class sprite_renderer
sprite_renderer = {}

sprite_renderer.layers = {}
sprite_renderer.layers.STAGE_BG   = 3
sprite_renderer.layers.CHARACTERS = 5
sprite_renderer.layers.GAME_BG    = 6
sprite_renderer.layers.BOBBLES    = 8


sprite_renderer.current_id = 0
-- sprite_renderer.sprites = {}

sprite_renderer.characters = {}


---@param self table
function sprite_renderer:init()
    table.insert(self.characters, character:new("Jimbo", sprite:new(data.defaults.missing_image, 0, 0, 1, 1, self.layers.CHARACTERS, 0, data.color.COLOR_WHITE), {data.defaults.missing_image}, {0}, 120))
end

sprite_renderer.clear_sprites = function (self)

end

---@param self table
---@param sprites table table containing Sprites
sprite_renderer.add_sprites = function (self, sprites)

end

function sprite_renderer:render()
    love.graphics.setColor(data.color.COLOR_WHITE)

    for _, character in pairs(self.characters) do
        character:draw(self.layers.CHARACTERS)
    end

end


return sprite_renderer
