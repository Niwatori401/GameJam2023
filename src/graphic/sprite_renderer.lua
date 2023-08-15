require("graphic/animation")
require("data")

---Responsible for rendering all sprites on screen.
---Layers are defined as follows:
---(1, 2, 3 - Stage Backgrounds, 4, 5 - characters, 6 - game area background, 7, 8 - Bobbles, 9)
sprite_renderer = {}

sprite_renderer.layers = {}
sprite_renderer.layers.STAGE_BG   = 3
sprite_renderer.layers.CHARACTERS = 5
sprite_renderer.layers.GAME_BG    = 6
sprite_renderer.layers.BOBBLES    = 8


sprite_renderer.current_id = 0

sprite_renderer.sprites = {}


---@param self table
sprite_renderer.init = function (self)
    for i = 1, 9 do
        self.sprites[i] = {}
    end


end

sprite_renderer.clear_sprites = function (self)
    for i = 1, 9 do
        self.sprites[i] = {}
    end
end

---@param self table
---@param sprites table table containing Sprites
sprite_renderer.add_sprites = function (self, sprites)
    for _, s in pairs(sprites) do
        table.insert(self.sprites[s.layer], s)
    end
end

sprite_renderer.render = function (self)
    love.graphics.setColor(color.COLOR_WHITE)

    for layer, sprites in ipairs(self.sprites) do
        for _, s in pairs(sprites) do
            love.graphics.setColor(s.color)
            love.graphics.draw(
                s.image,
                s.x,
                s.y,
                s.rotation,
                s.x_scale * window.SCREEN_X / s.image:getWidth(),
                s.y_scale * window.SCREEN_Y / s.image:getHeight()
            )
        end

    end




end
