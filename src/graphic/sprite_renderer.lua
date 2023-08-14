require("animation")
require("data")

sprite_renderer = {}
sprite_renderer.current_id = 0

sprite_renderer.sprites = {}
for i = 1, 9 do
    sprite_renderer.sprites[i] = {}
end

sprite_renderer.add_sprites = function (self, sprites)
    for _, s in pairs(sprites) do
        table.insert(self.sprites[s.layer], s)
    end
end

sprite_renderer.render = function (self)
    love.graphics.setColor(color.COLOR_WHITE)

    for layer, sprites in ipairs(t) do
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
