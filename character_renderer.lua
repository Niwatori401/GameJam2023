require("globals")
require("animation")

character_renderer = {}

character_renderer.pos_x = 0
character_renderer.pos_y = 0

character_renderer.start_animate_time = -1
character_renderer.start_scale_time = -1
character_renderer.scale = 1
character_renderer.color = {1,1,1,1}

character_renderer.render = function (self, character_sprite)

    if (self.start_animate_time == -1) then
        self.start_animate_time = GAME_TIME
    end

    if (self.start_scale_time == -1) then
        self.start_scale_time = GAME_TIME
    end

    --character_renderer.scale = animation.linear_interpolate(0.1, 1, self.start_scale_time, 0.5, GAME_TIME)
    character_renderer.pos_y = animation.linear_interpolate(SCREEN_Y, 0, self.start_animate_time, 0.7, GAME_TIME)


    love.graphics.setColor(character_renderer.color)
    love.graphics.draw(
        character_sprite,
        character_renderer.pos_x,
        character_renderer.pos_y,
        0,
        character_renderer.scale * SCREEN_X / character_sprite:getWidth(),
        character_renderer.scale * SCREEN_Y / character_sprite:getHeight())

end


