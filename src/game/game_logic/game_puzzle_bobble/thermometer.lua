local data = require("data")
local animation = require("graphic.animation")

local thermometer = {}

function thermometer:new(sprite, minimum_amount,  initial_max, current_amount, color, lowest_point_amount)

    local new_therm = setmetatable({}, {__index = thermometer})

    self.lowest_point_amount = lowest_point_amount
    self.sprite = sprite
    self.fluid_color = color
    self.minimum_amount = minimum_amount
    self.max_amount = initial_max
    self.current_amount = current_amount

    return new_therm
end

function thermometer:draw(layer)


    local circle_center_x = self.sprite.x + 64 * self.sprite.x_scale
    local circle_center_y = self.sprite.y + 957 * self.sprite.y_scale
    local circle_radius = 54 * self.sprite.y_scale
    love.graphics.setColor(self.fluid_color)
    love.graphics.circle("fill", circle_center_x, circle_center_y, circle_radius)

    local total_possible_height = 879 * self.sprite.y_scale
    local rectangle_height = total_possible_height * ((self.current_amount - self.lowest_point_amount) / (self.max_amount - self.lowest_point_amount))
    local rectangle_width = 70 * self.sprite.x_scale
    local rectangle_x = 28 * self.sprite.x_scale + self.sprite.x
    local rectangle_y = self.sprite.y + (914 * self.sprite.y_scale - rectangle_height)

    love.graphics.rectangle("fill", rectangle_x, rectangle_y, rectangle_width, rectangle_height)


    love.graphics.setColor(self.sprite.color)
    love.graphics.draw(
        self.sprite.image,
        self.sprite.x,
        self.sprite.y,
        0,
        self.sprite.x_scale,
        self.sprite.y_scale)
end


function thermometer:update(dt)
    for _, animation in pairs(self.sprite.animations) do
        self[animation.property_to_animate] = animation:increment_animation(data.game.game_time)
    end
end

function thermometer:set_max_amount(amt)
    self.max_amount = amt
end


function thermometer:add_amount_to_current(amt)
    local current_target = nil
    local animation_index = nil
    for key, animation in pairs(self.sprite.animations) do
        if animation.property_to_animate == "current_amount" then
            current_target = animation.final
            animation_index = key
        end
    end

    if current_target ~= nil then
        self.sprite.animations[animation_index] = animation:new(self.current_amount, current_target + amt, data.game.game_time, 1, animation.scheme_linear_interpolate, "current_amount")
    else
        table.insert(self.sprite.animations, animation:new(self.current_amount, self.current_amount + amt, data.game.game_time, 1, animation.scheme_linear_interpolate, "current_amount"))
    end

end


return thermometer
