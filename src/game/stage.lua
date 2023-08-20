local animation = require("graphic.animation")
local data = require("data")
local sprite = require("graphic.sprite")
local render_layer = require("graphic.render_layer")

---@class stage
local stage = {}
stage.__index = stage



---@param stage_background sprite
---@return stage
function stage:new(stage_background)

    local new_stage = {}
    setmetatable(new_stage, self)

    new_stage.black_background = sprite:new(
        data.defaults.black_image,
        0,
        0,
        1,
        1,
        render_layer.EFFECTS,
        0,
        {1,1,1,0.9})

    new_stage.stage_background = stage_background

    return new_stage
end


function stage:draw(layer)

    local s = self.stage_background

    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            s.x_scale * data.window.SCREEN_X / s.image:getWidth(),
            s.y_scale * data.window.SCREEN_Y / s.image:getHeight()
        )
    end

    s = self.black_background

    if layer == s.layer then
        love.graphics.setColor(s.color)
        love.graphics.draw(
            s.image,
            s.x,
            s.y,
            s.rotation,
            s.x_scale * data.window.SCREEN_X / s.image:getWidth(),
            s.y_scale * data.window.SCREEN_Y / s.image:getHeight()
        )
    end

end


---Used to tell the character to progress its animations
function stage:update_animations()
    --self:_update_all_animations_for_sprite(self.stage_background, data.game.game_time)
    self:_update_all_animations_for_sprite(self.black_background, data.game.game_time)
end



---Given a sprite, update all of its animations by passing in the time since last change.
-- Works for changing color
---@param s sprite
---@param cur_time number
function stage:_update_all_animations_for_sprite(s, cur_time)
    for _, animation in pairs(s.animations) do

        local new_value = animation:increment_animation(cur_time)

        s.color[animation.property_to_animate] = new_value

    end
end


function stage:animation_fade_in()

    table.insert(self.black_background.animations,
        animation:new(
            1,
            0,
            data.game.game_time,
            2.0,
            animation.scheme_linear_interpolate,
            data.game.game_time,
            4))
end


function stage:animation_fade_out()

    table.insert(self.black_background.animations,
        animation:new(
            0,
            1,
            data.game.game_time,
            0.5,
            animation.scheme_linear_interpolate,
            data.game.game_time,
            4))
end


return stage
